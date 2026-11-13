-- ============================================================
-- Vulnbox Lab — Sentinel Gateway — API de Gestão HTTP
-- Endpoints disponíveis em /_gateway/
-- ============================================================

local mode_dict   = ngx.shared.waf_mode
local config_dict = ngx.shared.waf_config
local rate_dict   = ngx.shared.waf_rate
local block_dict  = ngx.shared.waf_ip_block

local uri    = ngx.var.uri
local method = ngx.var.request_method

-- ============================================================
-- POST /_gateway/ui/config — atualiza parâmetros das regras WAF
-- ============================================================
if (uri == "/_gateway/ui/config" or uri == "/_gateway/config") and method == "POST" then
    ngx.req.read_body()
    local args = ngx.req.get_post_args()
    if not args or next(args) == nil then
        args = ngx.req.get_uri_args()
    end

    local function set_num(key)
        local val = tonumber(args[key])
        if val and val > 0 then
            config_dict:set(key, val)
        end
    end

    set_num("bf_limit")
    set_num("bf_window")
    set_num("bf_block_time")
    set_num("admin_limit")
    set_num("admin_block_time")
    set_num("idor_distinct_limit")
    set_num("idor_limit")
    set_num("idor_block_time")
    if args["admin_ip_whitelist"] ~= nil then
        config_dict:set("admin_ip_whitelist", tostring(args["admin_ip_whitelist"]))
    end

    ngx.log(ngx.WARN, "[GATEWAY-UI] WAF rule parameters updated")
    local ref = ngx.var.http_referer or "/_gateway/"
    ngx.redirect(ref, 302)
    return
end

-- ============================================================
-- POST /_gateway/ui/* — botões de UI (redireciona para o Referer ou /_gateway/)
-- ============================================================
if uri:find("^/_gateway/ui/") and method == "POST" then
    local action = uri:sub(#"/_gateway/ui/" + 1)
    if action == "activate" then
        mode_dict:set("mode", "active")
    elseif action == "deactivate" then
        mode_dict:set("mode", "passive")
    elseif action == "toggle" then
        local current = mode_dict:get("mode") or "active"
        mode_dict:set("mode", (current == "active") and "passive" or "active")
    elseif action == "reset" then
        block_dict:flush_all()
        rate_dict:flush_all()
    elseif action == "unblock" then
        ngx.req.read_body()
        local args = ngx.req.get_post_args()
        if not args or not args.ip then args = ngx.req.get_uri_args() end
        local unblock_ip = args and args.ip
        if unblock_ip then
            block_dict:delete(unblock_ip)
            rate_dict:delete("bf:"    .. unblock_ip)
            rate_dict:delete("admin:" .. unblock_ip)
            rate_dict:delete("idor_rate:" .. unblock_ip .. ":/profile.php")
            rate_dict:delete("idor_rate:" .. unblock_ip .. ":/document.php")
            rate_dict:delete("idor_ids:"  .. unblock_ip .. ":/profile.php")
            rate_dict:delete("idor_ids:"  .. unblock_ip .. ":/document.php")
            ngx.log(ngx.WARN, "[GATEWAY-UI] unblocked ip=" .. unblock_ip)
        end
    elseif action == "block" then
        ngx.req.read_body()
        local args = ngx.req.get_post_args()
        if not args or not args.ip then args = ngx.req.get_uri_args() end
        local block_ip = args and args.ip
        local block_time = tonumber(args and args.time) or 3600
        if block_ip and block_ip ~= "" then
            block_dict:set(block_ip, "MANUAL_BLOCK", block_time)
            ngx.log(ngx.WARN, "[GATEWAY-UI] manually blocked ip=" .. block_ip .. " for " .. block_time .. "s")
        end
    elseif action == "rule/toggle" then
        ngx.req.read_body()
        local args = ngx.req.get_post_args()
        if not args or not args.rule then args = ngx.req.get_uri_args() end
        local rname = args and args.rule
        if rname then
            local current = mode_dict:get("rule:" .. rname) or "active"
            mode_dict:set("rule:" .. rname, (current == "active") and "disabled" or "active")
        end
    elseif action == "rule/toggle_all" then
        local all_rules = {"IP_BLOCKLIST", "BRUTE_FORCE_LOGIN", "WEAK_PASSWORD_POLICY", "ADMIN_ENUMERATION", "IDOR_ENUMERATION", "PATH_TRAVERSAL", "SESSION_FIXATION_PROTECTION"}
        local all_active = true
        for _, r in ipairs(all_rules) do
            if (mode_dict:get("rule:" .. r) or "active") ~= "active" then
                all_active = false
                break
            end
        end
        local new_st = all_active and "disabled" or "active"
        for _, r in ipairs(all_rules) do
            mode_dict:set("rule:" .. r, new_st)
        end
        ngx.log(ngx.WARN, "[GATEWAY-UI] all rules toggled to " .. new_st)
    elseif action == "rule/activate_all" then
        local all_rules = {"IP_BLOCKLIST", "BRUTE_FORCE_LOGIN", "WEAK_PASSWORD_POLICY", "ADMIN_ENUMERATION", "IDOR_ENUMERATION", "PATH_TRAVERSAL", "SESSION_FIXATION_PROTECTION"}
        for _, r in ipairs(all_rules) do
            mode_dict:set("rule:" .. r, "active")
        end
        ngx.log(ngx.WARN, "[GATEWAY-UI] all rules activated")
    elseif action == "rule/deactivate_all" then
        local all_rules = {"IP_BLOCKLIST", "BRUTE_FORCE_LOGIN", "WEAK_PASSWORD_POLICY", "ADMIN_ENUMERATION", "IDOR_ENUMERATION", "PATH_TRAVERSAL", "SESSION_FIXATION_PROTECTION"}
        for _, r in ipairs(all_rules) do
            mode_dict:set("rule:" .. r, "disabled")
        end
        ngx.log(ngx.WARN, "[GATEWAY-UI] all rules deactivated")
    end
    local ref = ngx.var.http_referer
    if not ref or ref == "" then ref = "/_gateway/" end
    ngx.redirect(ref, 302)
    return
end

-- Helper JSON recursivo
local function json(t)
    if type(t) ~= "table" then
        if type(t) == "string" then
            return string.format('"%s"', t:gsub('"', '\\"'))
        elseif type(t) == "boolean" then
            return t and "true" or "false"
        else
            return tostring(t)
        end
    end
    local is_array = true
    local count = 0
    for k in pairs(t) do
        count = count + 1
        if type(k) ~= "number" or k ~= count then
            is_array = false
            break
        end
    end
    if is_array and count > 0 then
        local parts = {}
        for _, v in ipairs(t) do
            parts[#parts+1] = json(v)
        end
        return "[" .. table.concat(parts, ",") .. "]"
    end
    local parts = {}
    for k, v in pairs(t) do
        parts[#parts+1] = string.format('"%s":%s', k, json(v))
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

local function respond(data, status)
    ngx.status = status or 200
    ngx.header["Content-Type"]                = "application/json"
    ngx.header["Access-Control-Allow-Origin"] = "*"
    ngx.say(json(data))
    return ngx.exit(ngx.status)
end

-- ============================================================
-- GET /_gateway/status
-- Retorna o modo, parâmetros e IPs bloqueados em tempo real do WAF
-- ============================================================
if uri == "/_gateway/status" then
    local mode = mode_dict:get("mode") or "active"
    local all_rules = {"IP_BLOCKLIST", "BRUTE_FORCE_LOGIN", "WEAK_PASSWORD_POLICY", "ADMIN_ENUMERATION", "IDOR_ENUMERATION", "PATH_TRAVERSAL", "SESSION_FIXATION_PROTECTION"}
    local rules_status = {}
    for _, r in ipairs(all_rules) do
        rules_status[r] = mode_dict:get("rule:" .. r) or "active"
    end

    local blocked_list = {}
    local keys = block_dict:get_keys(100)
    for _, k_ip in ipairs(keys) do
        local r_name = block_dict:get(k_ip)
        local ttl = block_dict:ttl(k_ip)
        if ttl and ttl > 0 then
            table.insert(blocked_list, {
                ip   = k_ip,
                rule = r_name or "DESCONHECIDO",
                ttl  = math.ceil(ttl)
            })
        end
    end

    respond({
        mode        = mode,
        status      = (mode == "active") and "WAF ATIVO — bloqueando ataques A01/A07" or "WAF PASSIVO — modo proxy puro",
        rules       = rules_status,
        blocked_ips = blocked_list,
        params      = {
            bf_limit            = config_dict:get("bf_limit") or 10,
            bf_window           = config_dict:get("bf_window") or 3,
            bf_block_time       = config_dict:get("bf_block_time") or 10,
            admin_limit         = config_dict:get("admin_limit") or 15,
            admin_block_time    = config_dict:get("admin_block_time") or 10,
            idor_distinct_limit = config_dict:get("idor_distinct_limit") or 6,
            idor_limit          = config_dict:get("idor_limit") or 15,
            idor_block_time     = config_dict:get("idor_block_time") or 10,
            admin_ip_whitelist  = config_dict:get("admin_ip_whitelist") or "127.0.0.1",
        }
    })
    return
end

-- ============================================================
-- POST /_gateway/rule/toggle
-- Alterna o estado de uma regra específica (active ↔ disabled)
-- ============================================================
if uri == "/_gateway/rule/toggle" and method == "POST" then
    ngx.req.read_body()
    local args = ngx.req.get_post_args()
    if not args or not args.rule then args = ngx.req.get_uri_args() end
    local rname = args and args.rule
    if not rname then
        respond({ error = "Parâmetro 'rule' obrigatório. Ex: POST /_gateway/rule/toggle com rule=BRUTE_FORCE_LOGIN" }, 400)
        return
    end
    local cur = mode_dict:get("rule:" .. rname) or "active"
    local new_status = (cur == "active") and "disabled" or "active"
    mode_dict:set("rule:" .. rname, new_status)
    ngx.log(ngx.WARN, "[GATEWAY] rule toggled: " .. rname .. " (" .. cur .. " → " .. new_status .. ")")
    respond({
        rule = rname,
        status = new_status,
        message = (new_status == "active") and ("✅ Regra " .. rname .. " ATIVADA") or ("⚠️ Regra " .. rname .. " DESATIVADA")
    })
    return
end

-- ============================================================
-- POST /_gateway/rule/toggle_all
-- Alterna o estado de todas as regras WAF de uma vez (active ↔ disabled)
-- ============================================================
if uri == "/_gateway/rule/toggle_all" and method == "POST" then
    local all_rules = {"IP_BLOCKLIST", "BRUTE_FORCE_LOGIN", "WEAK_PASSWORD_POLICY", "ADMIN_ENUMERATION", "IDOR_ENUMERATION", "PATH_TRAVERSAL", "SESSION_FIXATION_PROTECTION"}
    local all_active = true
    for _, r in ipairs(all_rules) do
        if (mode_dict:get("rule:" .. r) or "active") ~= "active" then
            all_active = false
            break
        end
    end
    local new_st = all_active and "disabled" or "active"
    for _, r in ipairs(all_rules) do
        mode_dict:set("rule:" .. r, new_st)
    end
    ngx.log(ngx.WARN, "[GATEWAY] all rules toggled: " .. (all_active and "active -> disabled" or "disabled/mixed -> active"))
    respond({
        status = (new_st == "active")
            and "✅ Todas as regras WAF foram ATIVADAS"
            or  "⚠️ Todas as regras WAF foram DESATIVADAS",
        all_rules_status = new_st
    })
    return
end

-- ============================================================
-- POST /_gateway/rule/activate_all
-- Ativa todas as regras de uma vez
-- ============================================================
if uri == "/_gateway/rule/activate_all" and method == "POST" then
    local all_rules = {"IP_BLOCKLIST", "BRUTE_FORCE_LOGIN", "WEAK_PASSWORD_POLICY", "ADMIN_ENUMERATION", "IDOR_ENUMERATION", "PATH_TRAVERSAL", "SESSION_FIXATION_PROTECTION"}
    for _, r in ipairs(all_rules) do
        mode_dict:set("rule:" .. r, "active")
    end
    ngx.log(ngx.WARN, "[GATEWAY] all rules activated")
    respond({ status = "✅ Todas as regras WAF foram ATIVADAS" })
    return
end

-- ============================================================
-- POST /_gateway/rule/deactivate_all
-- Desativa todas as regras de uma vez
-- ============================================================
if uri == "/_gateway/rule/deactivate_all" and method == "POST" then
    local all_rules = {"IP_BLOCKLIST", "BRUTE_FORCE_LOGIN", "WEAK_PASSWORD_POLICY", "ADMIN_ENUMERATION", "IDOR_ENUMERATION", "PATH_TRAVERSAL", "SESSION_FIXATION_PROTECTION"}
    for _, r in ipairs(all_rules) do
        mode_dict:set("rule:" .. r, "disabled")
    end
    ngx.log(ngx.WARN, "[GATEWAY] all rules deactivated")
    respond({ status = "⚠️ Todas as regras WAF foram DESATIVADAS" })
    return
end

-- ============================================================
-- POST /_gateway/toggle
-- Alterna entre active ↔ passive
-- ============================================================
if uri == "/_gateway/toggle" and method == "POST" then
    local current  = mode_dict:get("mode") or "active"
    local new_mode = (current == "active") and "passive" or "active"
    mode_dict:set("mode", new_mode)
    ngx.log(ngx.WARN, "[GATEWAY] mode toggled: " .. current .. " → " .. new_mode)
    respond({
        mode    = new_mode,
        previous = current,
        status  = (new_mode == "active")
            and "✅ WAF ATIVADO — ataques serão bloqueados"
            or  "⚠️  WAF DESATIVADO — todos os ataques passarão",
    })
    return
end

-- ============================================================
-- POST /_gateway/activate
-- Força modo active
-- ============================================================
if uri == "/_gateway/activate" and method == "POST" then
    mode_dict:set("mode", "active")
    ngx.log(ngx.WARN, "[GATEWAY] WAF activated")
    respond({
        mode   = "active",
        status = "✅ WAF ATIVADO — bloqueando ataques A01 e A07",
    })
    return
end

-- ============================================================
-- POST /_gateway/deactivate
-- Força modo passive
-- ============================================================
if uri == "/_gateway/deactivate" and method == "POST" then
    mode_dict:set("mode", "passive")
    ngx.log(ngx.WARN, "[GATEWAY] WAF deactivated")
    respond({
        mode   = "passive",
        status = "⚠️  WAF DESATIVADO — proxy puro, vulnerabilidades expostas",
    })
    return
end

-- ============================================================
-- POST /_gateway/reset
-- Limpa todos os bloqueios e contadores de rate limit
-- ============================================================
if uri == "/_gateway/reset" and method == "POST" then
    block_dict:flush_all()
    rate_dict:flush_all()
    ngx.log(ngx.WARN, "[GATEWAY] all blocks and rate limits cleared")
    respond({
        status = "✅ Todos os bloqueios e contadores foram limpos",
    })
    return
end

-- ============================================================
-- POST /_gateway/unblock?ip=x.x.x.x
-- Desbloqueia um IP específico
-- ============================================================
if uri == "/_gateway/unblock" and method == "POST" then
    ngx.req.read_body()
    local args = ngx.req.get_post_args()
    if not args or not args.ip then args = ngx.req.get_uri_args() end
    local ip = args and args.ip
    if not ip then
        respond({ error = "Parâmetro 'ip' obrigatório. Ex: /_gateway/unblock?ip=172.20.10.1" }, 400)
        return
    end
    local was_blocked = block_dict:get(ip) ~= nil
    block_dict:delete(ip)
    -- Limpa contadores desse IP
    rate_dict:delete("bf:"    .. ip)
    rate_dict:delete("admin:" .. ip)
    rate_dict:delete("idor_rate:" .. ip .. ":/profile.php")
    rate_dict:delete("idor_rate:" .. ip .. ":/document.php")
    rate_dict:delete("idor_ids:"  .. ip .. ":/profile.php")
    rate_dict:delete("idor_ids:"  .. ip .. ":/document.php")
    ngx.log(ngx.WARN, "[GATEWAY] unblocked ip=" .. ip)
    respond({
        ip          = ip,
        was_blocked = was_blocked,
        status      = "✅ IP desbloqueado e contadores limpos",
    })
    return
end

-- ============================================================
-- POST /_gateway/block?ip=x.x.x.x&time=3600
-- Bloqueia um IP manualmente na IP_BLOCKLIST
-- ============================================================
if uri == "/_gateway/block" and method == "POST" then
    ngx.req.read_body()
    local args = ngx.req.get_post_args()
    if not args or not args.ip then args = ngx.req.get_uri_args() end
    local ip = args and args.ip
    local time_sec = tonumber(args and args.time) or 3600
    if not ip or ip == "" then
        respond({ error = "Parâmetro 'ip' obrigatório. Ex: /_gateway/block?ip=192.168.1.50" }, 400)
        return
    end
    block_dict:set(ip, "MANUAL_BLOCK", time_sec)
    ngx.log(ngx.WARN, "[GATEWAY] manually blocked ip=" .. ip .. " for " .. time_sec .. "s")
    respond({
        ip     = ip,
        time   = time_sec,
        status = "✅ IP bloqueado manualmente com sucesso e adicionado à IP_BLOCKLIST",
    })
    return
end

-- ============================================================
-- GET /_gateway/  — página de controle HTML
-- ============================================================
if uri == "/_gateway/" or uri == "/_gateway" then
    local mode = mode_dict:get("mode") or "active"
    local is_active = (mode == "active")
    local mode_label = is_active and "Ativado" or "Desativado"
    local mode_class = is_active and "active" or "passive"
    local mode_icon  = is_active and "🟢" or "🟠"
    local btn_class  = is_active and "btn-active" or "btn-passive"
    local next_action = is_active and "Desativar" or "Ativar"

    -- Lê parâmetros atuais da shared dict
    local bf_limit            = config_dict:get("bf_limit") or 3
    local bf_window           = config_dict:get("bf_window") or 3
    local bf_block_time       = config_dict:get("bf_block_time") or 3600
    local admin_limit         = config_dict:get("admin_limit") or 3
    local admin_block_time    = config_dict:get("admin_block_time") or 3600
    local idor_distinct_limit = config_dict:get("idor_distinct_limit") or 3
    local idor_limit          = config_dict:get("idor_limit") or 15
    local idor_block_time     = config_dict:get("idor_block_time") or 3600
    local admin_ip_whitelist  = config_dict:get("admin_ip_whitelist") or "127.0.0.1"

    -- Lista de IPs Bloqueados no Momento
    local blocked_list = {}
    local keys = block_dict:get_keys(100)
    for _, k_ip in ipairs(keys) do
        local r_name = block_dict:get(k_ip)
        local ttl = block_dict:ttl(k_ip)
        if ttl and ttl > 0 then
            table.insert(blocked_list, {
                ip   = k_ip,
                rule = r_name or "DESCONHECIDO",
                ttl  = math.ceil(ttl)
            })
        end
    end

    local blocked_rows = {}
    if #blocked_list == 0 then
        table.insert(blocked_rows, '<tr><td colspan="4" style="color:#8b949e;text-align:center;padding:12px">Nenhum IP bloqueado no momento (0 bloqueios ativos)</td></tr>')
    else
        for _, b in ipairs(blocked_list) do
            table.insert(blocked_rows, string.format([[
    <tr>
      <td><code style="color:#f85149;font-weight:bold">%s</code></td>
      <td><span class="badge badge-passive">%s</span></td>
      <td>⏱️ <strong>%ds</strong> restantes</td>
      <td>
        <form method="POST" action="/_gateway/ui/unblock" style="margin:0">
          <input type="hidden" name="ip" value="%s">
          <button type="submit" class="btn btn-reset btn-sm">🔓 Desbloquear IP (Falso Positivo)</button>
        </form>
      </td>
    </tr>]], b.ip, b.rule, b.ttl, b.ip))
        end
    end
    local blocked_table_html = table.concat(blocked_rows, "\n")

    local rules_def = {
        { num = 1, name = "IP_BLOCKLIST", label = "A01/A07 — Reincidência / IP Blocklist", limit = "IP já bloqueado por violação", action = "403 imediato" },
        { num = 2, name = "BRUTE_FORCE_LOGIN", label = "A07 — Força Bruta no Login", limit = string.format("&gt;%d tentativas em %ds", bf_limit, bf_window), action = string.format("429 + bloqueia IP por %ds", bf_block_time) },
        { num = 3, name = "WEAK_PASSWORD_POLICY", label = "A07 — Política de Senha Fraca", limit = "Tamanho &lt;8, dicionário ou sem complexidade", action = "400 Rejeita submissão" },
        { num = 4, name = "ADMIN_ENUMERATION", label = "A01 — Escalada Vertical & Rotas Admin", limit = string.format("&gt;%d req /admin/*/min", admin_limit), action = string.format("403 + bloqueia IP por %ds", admin_block_time) },
        { num = 5, name = "IDOR_ENUMERATION", label = "A01 — IDOR Perfis & Documentos", limit = string.format("&gt;%d IDs distintos ou &gt;%d req/min", idor_distinct_limit, idor_limit), action = string.format("403 + bloqueia IP por %ds", idor_block_time) },
        { num = 6, name = "PATH_TRAVERSAL", label = "A01 — Path Traversal & Arquivos Sensíveis", limit = "Padrões ../ ou arquivos .env/.git/src/sql", action = "403 imediato" },
        { num = 7, name = "SESSION_FIXATION_PROTECTION", label = "A07 — Proteção contra Session Fixation", limit = "PHP não renova PHPSESSID no login", action = "Virtual Patching: Injeta novo PHPSESSID" },
    }

    local rules_rows = {}
    for _, r in ipairs(rules_def) do
        local r_st = mode_dict:get("rule:" .. r.name) or "active"
        local is_r_active = (r_st == "active")
        local btn_cls = is_r_active and "btn-active" or "btn-passive"
        local icon = is_r_active and "🟢" or "🔴"
        local txt = is_r_active and "Ativada" or "Desativada"
        table.insert(rules_rows, string.format([[
    <tr>
      <td style="text-align:center;font-weight:bold;color:#58a6ff">#%d</td>
      <td><code>%s</code></td>
      <td>%s</td>
      <td>%s</td>
      <td>%s</td>
      <td>
        <form method="POST" action="/_gateway/ui/rule/toggle" style="margin:0">
          <input type="hidden" name="rule" value="%s">
          <button type="submit" class="btn %s btn-sm">%s %s</button>
        </form>
      </td>
    </tr>]], r.num, r.name, r.label, r.limit, r.action, r.name, btn_cls, icon, txt))
    end
    local rules_table_html = table.concat(rules_rows, "\n")

    local all_rules_active = true
    for _, r in ipairs(rules_def) do
        if (mode_dict:get("rule:" .. r.name) or "active") ~= "active" then
            all_rules_active = false
            break
        end
    end
    local batch_btn_cls = all_rules_active and "btn-active" or "btn-passive"
    local batch_icon    = all_rules_active and "🟢" or "🔴"
    local batch_label   = all_rules_active and "Ativadas" or "Desativadas"
    local batch_action  = all_rules_active and "Desativar" or "Ativar"

    local blocked_badge_html = (#blocked_list > 0)
        and string.format('<span class="badge-count">%d</span>', #blocked_list)
        or '<span class="badge-count badge-count-zero">0</span>'

    ngx.header["Content-Type"] = "text/html; charset=UTF-8"
    ngx.print(string.format([[<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>🛡️ Sentinel Gateway</title>
  <style>
    *{box-sizing:border-box}
    body{font-family:monospace;background:#0d1117;color:#e6edf3;padding:40px;max-width:950px;margin:0 auto}
    h1{color:#58a6ff;margin-bottom:16px}
    h2{color:#3fb950;margin-top:0;font-size:1.3em}
    table{width:100%%;border-collapse:collapse;margin:12px 0}
    th{background:#161b22;color:#8b949e;text-align:left;padding:10px 12px;border-bottom:1px solid #30363d}
    td{padding:10px 12px;border-top:1px solid #21262d;vertical-align:middle}
    code{background:#161b22;padding:2px 6px;border-radius:4px;color:#f97316}
    .badge{display:inline-block;padding:6px 14px;border-radius:20px;font-size:1em;font-weight:bold}
    .badge-active{background:#1a3a1a;border:1px solid #3fb950;color:#3fb950}
    .badge-passive{background:#3a2a00;border:1px solid #ffa500;color:#ffa500}
    .actions-panel{background:#161b22;border:1px solid #30363d;border-radius:8px;padding:20px;margin:20px 0;display:flex;gap:16px;flex-wrap:wrap;align-items:center}
    .config-card{background:#161b22;border:1px solid #30363d;border-radius:8px;padding:20px;margin:16px 0}
    .form-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:16px;margin:16px 0}
    .form-group{display:flex;flex-direction:column;gap:6px}
    .form-group label{font-size:0.85em;color:#8b949e}
    .form-group input{background:#0d1117;border:1px solid #30363d;border-radius:4px;color:#e6edf3;padding:8px 10px;font-family:monospace;font-size:13px}
    .form-group input:focus{outline:none;border-color:#58a6ff}
    .btn{padding:10px 22px;border-radius:6px;border:none;cursor:pointer;font-family:monospace;font-weight:bold;font-size:14px;transition:opacity .2s}
    .btn:hover{opacity:0.85}
    .btn-active{background:#238636;color:#ffffff}
    .btn-passive{background:#d97706;color:#ffffff}
    .btn-reset{background:#da3633;color:#ffffff}
    .btn-save{background:#238636;color:#ffffff;margin-top:12px}
    .btn-sm{padding:4px 10px;font-size:11px}

    /* Menu de Abas (Tab System) */
    .nav-tabs{display:flex;gap:8px;border-bottom:2px solid #30363d;margin:24px 0 20px 0}
    .tab-btn{background:#161b22;color:#8b949e;border:1px solid #30363d;border-bottom:none;border-radius:6px 6px 0 0;padding:10px 18px;font-family:monospace;font-size:13px;font-weight:bold;cursor:pointer;transition:all 0.2s;position:relative;bottom:-2px}
    .tab-btn:hover{background:#21262d;color:#e6edf3}
    .tab-btn.active{background:#21262d;color:#58a6ff;border-color:#58a6ff;border-bottom:2px solid #21262d}
    .tab-content{display:none}
    .tab-content.active{display:block}
    .badge-count{background:#da3633;color:#fff;padding:2px 7px;border-radius:10px;font-size:11px;margin-left:6px}
    .badge-count-zero{background:#30363d;color:#8b949e}
  </style>
</head>
<body>
  <h1>🛡️ Sentinel Gateway</h1>

  <!-- Controle Geral de Estado (Global) — Sempre Visível no Topo -->
  <div class="actions-panel">
    <strong style="width:100%%;margin-bottom:6px">Controle Geral de Estado (Global):</strong>
    <form method="POST" action="/_gateway/ui/toggle" style="margin:0">
      <button type="submit" class="btn %s">
        %s WAF %s (Clique para %s)
      </button>
    </form>
    <form method="POST" action="/_gateway/ui/reset" style="margin:0">
      <button type="submit" class="btn btn-reset">🧹 Limpar Todos os Bloqueios</button>
    </form>
  </div>

  <!-- Menu de Navegação por Seções -->
  <div class="nav-tabs">
    <button class="tab-btn" data-tab="tab-ips" onclick="switchTab('tab-ips', true)">
      🚫 IPs Bloqueados %s
    </button>
    <button class="tab-btn" data-tab="tab-config" onclick="switchTab('tab-config', true)">
      ⚙️ Ajuste de Parâmetros
    </button>
    <button class="tab-btn" data-tab="tab-rules" onclick="switchTab('tab-rules', true)">
      🛡️ Regras WAF
    </button>
  </div>

  <!-- SEÇÃO 1: IPs Bloqueados no Momento (Lista Ativa) -->
  <div id="tab-ips" class="tab-content">
    <div style="background:#161b22;border:1px solid #30363d;border-radius:6px;padding:16px;margin-bottom:20px">
      <h3 style="margin-bottom:12px;font-size:1em;color:#58a6ff">➕ Bloquear IP Manualmente (Regra 1 — IP Blocklist)</h3>
      <form method="POST" action="/_gateway/ui/block" style="display:flex;gap:12px;align-items:center;flex-wrap:wrap">
        <input type="text" name="ip" placeholder="Endereço IP (ex: 192.168.1.100)" required style="padding:6px 12px;border-radius:4px;border:1px solid #30363d;background:#0d1117;color:#e6edf3;font-family:monospace;width:240px">
        <input type="number" name="time" value="3600" placeholder="Tempo em segundos" required style="padding:6px 12px;border-radius:4px;border:1px solid #30363d;background:#0d1117;color:#e6edf3;font-family:monospace;width:160px">
        <button type="submit" class="btn btn-reset">⛔ Bloquear IP</button>
      </form>
    </div>
    <h2>🚫 IPs Bloqueados no Momento (Lista Ativa)</h2>
    <table>
      <tr><th>IP Bloqueado</th><th>Regra Causadora</th><th>Tempo Restante (TTL)</th><th>Ação / Falso Positivo</th></tr>
%s
    </table>
  </div>

  <!-- SEÇÃO 2: Ajuste de Parâmetros de Bloqueio -->
  <div id="tab-config" class="tab-content">
    <h2>⚙️ Ajuste de Parâmetros de Bloqueio</h2>
    <div class="config-card">
      <form method="POST" action="/_gateway/ui/config">
        <h3 style="color:#58a6ff;font-size:1em;margin-bottom:8px">1. Força Bruta (Login)</h3>
        <div class="form-grid">
          <div class="form-group">
            <label>Máx. Tentativas de Login:</label>
            <input type="number" name="bf_limit" value="%d" min="1" required>
          </div>
          <div class="form-group">
            <label>Janela de Monitoramento (segundos):</label>
            <input type="number" name="bf_window" value="%d" min="1" required>
          </div>
          <div class="form-group">
            <label>Duração do Bloqueio de IP (segundos):</label>
            <input type="number" name="bf_block_time" value="%d" min="5" required>
          </div>
        </div>

        <h3 style="color:#58a6ff;font-size:1em;margin-top:16px;margin-bottom:8px">2. Enumeração & Acesso a Rotas Admin</h3>
        <div class="form-grid">
          <div class="form-group">
            <label>Máx. Requisições Admin / min:</label>
            <input type="number" name="admin_limit" value="%d" min="1" required>
          </div>
          <div class="form-group">
            <label>Duração do Bloqueio (segundos):</label>
            <input type="number" name="admin_block_time" value="%d" min="5" required>
          </div>
          <div class="form-group" style="grid-column:1/-1">
            <label>IPs Autorizados para Área Admin (Whitelist, separados por vírgula):</label>
            <input type="text" name="admin_ip_whitelist" value="%s" placeholder="ex: 172.20.0.1, 127.0.0.1">
          </div>
        </div>

        <h3 style="color:#58a6ff;font-size:1em;margin-top:16px;margin-bottom:8px">3. IDOR (Perfis e Documentos)</h3>
        <div class="form-grid">
          <div class="form-group">
            <label>Máx. IDs Distintos / min:</label>
            <input type="number" name="idor_distinct_limit" value="%d" min="1" required>
          </div>
          <div class="form-group">
            <label>Máx. Requisições Totais / min:</label>
            <input type="number" name="idor_limit" value="%d" min="1" required>
          </div>
          <div class="form-group">
            <label>Duração do Bloqueio (segundos):</label>
            <input type="number" name="idor_block_time" value="%d" min="5" required>
          </div>
        </div>

        <button type="submit" class="btn btn-save">💾 Salvar e Aplicar Parâmetros</button>
      </form>
    </div>
  </div>

  <!-- SEÇÃO 3: Regras WAF (Controle Individual por Regra) -->
  <div id="tab-rules" class="tab-content">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;flex-wrap:wrap;gap:12px">
      <h2 style="margin:0">🛡️ Regras WAF (Controle Individual por Regra)</h2>
      <form method="POST" action="/_gateway/ui/rule/toggle_all" style="margin:0">
        <button type="submit" class="btn %s btn-sm">%s Regras %s (Clique para %s)</button>
      </form>
    </div>
    <table>
      <tr><th>#</th><th>Identificador da Regra</th><th>Ataque / OWASP</th><th>Limite / Padrão</th><th>Ação</th><th>Status / Toggle</th></tr>
%s
    </table>
  </div>

  <p style="margin-top:24px;color:#6e7681;font-size:.85em">
    Vulnbox Lab — Sentinel Gateway v1.0 | OpenResty %s
  </p>

  <script>
    function switchTab(tabId, isManualClick) {
      var currentSaved = localStorage.getItem('gateway_active_tab');
      try { localStorage.setItem('gateway_active_tab', tabId); } catch(e){}
      window.location.hash = tabId;

      if (isManualClick) {
        window.location.reload();
        return;
      }

      document.querySelectorAll('.tab-content').forEach(function(el) { el.classList.remove('active'); });
      document.querySelectorAll('.tab-btn').forEach(function(el) { el.classList.remove('active'); });
      
      var target = document.getElementById(tabId);
      if (target) target.classList.add('active');
      
      var btn = document.querySelector('[data-tab="' + tabId + '"]');
      if (btn) btn.classList.add('active');
    }

    document.addEventListener('DOMContentLoaded', function() {
      var hash = window.location.hash.replace('#', '');
      var saved = localStorage.getItem('gateway_active_tab');
      var initial = hash || saved || 'tab-ips';
      if (!document.getElementById(initial)) initial = 'tab-ips';
      switchTab(initial, false);

      // Reload automático a cada 5 segundos na aba de IPs bloqueados para atualizar o TTL em tempo real
      if (initial === 'tab-ips') {
        setTimeout(function() {
          if (localStorage.getItem('gateway_active_tab') === 'tab-ips') {
            window.location.reload();
          }
        }, 5000);
      }
    });
  </script>
</body>
</html>]],
        btn_class, mode_icon, mode_label, next_action,
        blocked_badge_html,
        blocked_table_html,
        bf_limit, bf_window, bf_block_time,
        admin_limit, admin_block_time, admin_ip_whitelist,
        idor_distinct_limit, idor_limit, idor_block_time,
        batch_btn_cls, batch_icon, batch_label, batch_action,
        rules_table_html,
        ngx.var.nginx_version or ""))
    return ngx.exit(200)
end

-- 404 para endpoints desconhecidos
respond({ error = "Endpoint desconhecido. Consulte GET /_gateway/ para ajuda." }, 404)
