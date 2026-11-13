-- ============================================================
-- Sentinel Security Gateway - WAF Rules (Lua)
-- Executa na fase access_by_lua para cada requisicao
-- ============================================================

local mode_dict   = ngx.shared.waf_mode
local config_dict = ngx.shared.waf_config
local rate_dict   = ngx.shared.waf_rate
local block_dict  = ngx.shared.waf_ip_block

local mode = mode_dict:get("mode") or "active"

-- Modo passivo: proxy puro, sem bloqueio
if mode ~= "active" then
    ngx.log(ngx.INFO, "[WAF:PASSIVE] bypass -> ", ngx.var.uri)
    return
end

-- Contexto da requisicao
local ip     = ngx.var.remote_addr
local uri    = ngx.var.uri
local method = ngx.var.request_method
local ua     = ngx.var.http_user_agent or ""
local qs     = ngx.var.query_string    or ""

-- Parametros de Configuracao Dinamicos
local bf_limit            = config_dict:get("bf_limit")            or 3
local bf_window           = config_dict:get("bf_window")           or 3
local bf_block_time       = config_dict:get("bf_block_time")       or 3600
local admin_limit         = config_dict:get("admin_limit")         or 3
local admin_block_time    = config_dict:get("admin_block_time")    or 3600
local idor_distinct_limit = config_dict:get("idor_distinct_limit") or 3
local idor_limit          = config_dict:get("idor_limit")          or 15
local idor_block_time     = config_dict:get("idor_block_time")     or 3600

-- ============================================================
-- Helper: resposta de bloqueio HTML
-- ============================================================
local function block(status, rule, detail)
    ngx.log(ngx.WARN, string.format(
        "[WAF:BLOCK] ip=%s rule=%s uri=%s detail=%s",
        ip, rule, uri, detail or ""
    ))
    ngx.status = status
    ngx.header["Content-Type"]  = "text/html; charset=UTF-8"
    ngx.header["X-WAF-Rule"]    = rule
    ngx.header["X-WAF-Mode"]    = "active"
    ngx.print(string.format([[<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Sentinel Gateway - Acesso Bloqueado</title>
  <style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:monospace;background:#0d1117;color:#e6edf3;display:flex;
         align-items:center;justify-content:center;min-height:100vh}
    .card{background:#161b22;border:1px solid #ff4444;border-radius:8px;
          padding:40px;max-width:600px;width:90%%;text-align:center}
    .icon{font-size:64px;margin-bottom:16px}
    h1{color:#ff4444;font-size:1.6em;margin-bottom:12px}
    .rule{background:#1f2937;border-left:4px solid #ff4444;padding:12px 16px;
          border-radius:4px;margin:20px 0;text-align:left;font-size:.9em}
    .rule span{color:#ffa500}
    .footer{margin-top:24px;font-size:.8em;color:#6e7681}
    .http{font-size:2em;color:#ff4444;font-weight:bold}
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">BLOCKED</div>
    <h1>Sentinel Gateway</h1>
    <p class="http">HTTP %d</p>
    <p style="margin:12px 0">Esta requisicao foi <strong>bloqueada pelo WAF</strong>.</p>
    <div class="rule">
      <div><span>Regra  :</span> %s</div>
      <div><span>IP     :</span> %s</div>
      <div><span>URI    :</span> %s</div>
      <div><span>Detalhe:</span> %s</div>
    </div>
    <div class="footer">
      Vulnbox Lab - Sentinel Gateway (modo ativo)<br>
      Para desativar: <code>curl -X POST http://localhost:8080/_gateway/deactivate</code>
    </div>
  </div>
</body>
</html>]], status, rule, ip, uri, detail or ""))
    return ngx.exit(status)
end

local function is_rule_active(rule_name)
    local status = mode_dict:get("rule:" .. rule_name)
    return status == nil or status == "active"
end

local function is_ip_whitelisted(client_ip, whitelist_str)
    if not whitelist_str or whitelist_str == "" then return false end
    for allowed in string.gmatch(whitelist_str, "[^,%s]+") do
        if allowed == client_ip then
            return true
        end
    end
    return false
end

local whitelist_str  = config_dict:get("admin_ip_whitelist") or "127.0.0.1"
local is_whitelisted = is_ip_whitelisted(ip, whitelist_str)

-- ============================================================
-- REGRA 1: IP Bloqueado (violacoes previas A01/A07 ou bloqueio manual)
-- ============================================================
local orig_rule = block_dict:get(ip)
if is_rule_active("IP_BLOCKLIST") and not is_whitelisted and orig_rule then
    block(403, "IP_BLOCKLIST",
        string.format("IP %s bloqueado por atividade suspeita (Regra de origem: %s)", ip, tostring(orig_rule)))
end

-- ============================================================
-- REGRA 2: Forca Bruta no Login (A07) e Mapeamento de Sessao (A01)
-- ============================================================
if uri == "/login.php" and method == "POST" then
    ngx.req.read_body()
    local post_args = ngx.req.get_post_args()
    if post_args and post_args.username then
        ngx.ctx.login_user = post_args.username
        local sess_id = ngx.var.cookie_PHPSESSID
        if sess_id then
            local role = (post_args.username:lower() == "admin") and "admin" or "user"
            rate_dict:set("role:" .. sess_id, role, 3600)
        end
    end

    if is_rule_active("BRUTE_FORCE_LOGIN") then
        local key   = "bf:" .. ip
        local count = rate_dict:incr(key, 1, 0, bf_window)
        if count == nil then
            rate_dict:set(key, 1, bf_window)
            count = 1
        end
        ngx.log(ngx.INFO, string.format(
            "[WAF:RATE] brute_force ip=%s count=%d limit=%d", ip, count, bf_limit))
        if count > bf_limit then
            block_dict:set(ip, "BRUTE_FORCE_LOGIN", bf_block_time)
            ngx.header["Retry-After"] = tostring(bf_block_time)
            block(429, "BRUTE_FORCE_LOGIN",
                string.format(
                    "Excedeu %d tentativas de login em %ds. IP bloqueado por %ds. (tentativa #%d)",
                    bf_limit, bf_window, bf_block_time, count))
        end
    end
end

-- ============================================================
-- REGRA 3: Politica de Senha Fraca (A07)
-- Verifica tamanho, dicionario de senhas conhecidas e complexidade.
-- Aplica-se a /login.php (campo: password) e /change-password.php (campo: new_password).
-- A lista usa minusculas; a senha e convertida com :lower() para comparacao
-- case-insensitive. Complexidade e tamanho usam o valor original da senha.
-- ============================================================
local function check_weak_password(pass)
    local pass_lower = pass:lower()

    -- 1. Tamanho minimo (padrao: 8 caracteres)
    local min_length = config_dict:get("min_password_len") or 8
    if #pass < min_length then
        block(400, "WEAK_PASSWORD_POLICY",
            string.format("Senha rejeitada: possui %d caracteres (minimo exigido: %d)", #pass, min_length))
    end

    -- 2. Dicionario de senhas fracas conhecidas (todos em minusculas)
    local known_weak = {
        "123456", "12345678", "123456789", "12345", "password",
        "qwerty", "admin123", "manager123", "1234567", "letmein",
        "welcome", "admin", "user123", "mudar123", "senha123", "a12345678", "a123456789"
    }
    for _, weak in ipairs(known_weak) do
        if pass_lower == weak then
            block(400, "WEAK_PASSWORD_POLICY",
                string.format("Senha fraca rejeitada: '%s' consta na lista de senhas conhecidas", pass))
        end
    end

    -- 3. Complexidade: exige pelo menos uma letra e um numero
    local has_letter = pass:find("%a") ~= nil
    local has_digit  = pass:find("%d") ~= nil
    if not (has_letter and has_digit) then
        block(400, "WEAK_PASSWORD_POLICY",
            "Senha sem complexidade: deve conter pelo menos uma letra e um numero")
    end
end

if is_rule_active("WEAK_PASSWORD_POLICY") and method == "POST" then
    if uri == "/login.php" or uri == "/change-password.php" then
        ngx.req.read_body()
        local post_args = ngx.req.get_post_args()
        local pass = post_args and (post_args.password or post_args.new_password)
        if pass then
            check_weak_password(pass)
        end
    end
end

-- ============================================================
-- REGRA 4: Escalada Vertical e Enumeracao Admin (A01)
-- ============================================================
if is_rule_active("ADMIN_ENUMERATION") and uri:sub(1, 6) == "/admin" then
    local sess_id        = ngx.var.cookie_PHPSESSID
    local user_role      = sess_id and rate_dict:get("role:" .. sess_id)
    local whitelist_str2 = config_dict:get("admin_ip_whitelist") or "127.0.0.1"
    local is_wl2         = is_ip_whitelisted(ip, whitelist_str2)

    ngx.log(ngx.WARN, string.format("[WAF:ADMIN_CHECK] uri=%s ip=%s whitelisted=%s role=%s",
        uri, ip, tostring(is_wl2), tostring(user_role)))

    if not is_wl2 and user_role ~= "admin" then
        local key   = "admin:" .. ip
        local count = rate_dict:incr(key, 1, 0, 60)
        if count == nil then
            rate_dict:set(key, 1, 60)
            count = 1
        end
        if count > admin_limit then
            block_dict:set(ip, "ADMIN_ENUMERATION", admin_block_time)
            block(403, "ADMIN_ENUMERATION",
                string.format(
                    "Enumeracao de rotas administrativas detectada (%d req/min > limite %d)", count, admin_limit))
        else
            block(403, "ADMIN_ACCESS_DENIED",
                string.format("Acesso negado: Rota /admin/ restrita. IP %s nao esta na Whitelist e a sessao nao e de Administrador (A01)", ip))
        end
    end
end

-- ============================================================
-- REGRA 5: IDOR - Enumeracao de Perfis e Documentos (A01)
-- ============================================================
if is_rule_active("IDOR_ENUMERATION") and (uri == "/profile.php" or uri == "/document.php") then
    local sess_id        = ngx.var.cookie_PHPSESSID
    local user_role      = sess_id and rate_dict:get("role:" .. sess_id)
    local whitelist_str3 = config_dict:get("admin_ip_whitelist") or "127.0.0.1"
    local is_wl3         = is_ip_whitelisted(ip, whitelist_str3)

    if not is_wl3 and user_role ~= "admin" then
        local args   = ngx.req.get_uri_args()
        local id_val = args and args.id

        if id_val then
            local rate_key = "idor_rate:" .. ip .. ":" .. uri
            local count    = rate_dict:incr(rate_key, 1, 0, 60)
            if count == nil then
                rate_dict:set(rate_key, 1, 60)
                count = 1
            end

            local ids_key  = "idor_ids:" .. ip .. ":" .. uri
            local ids_seen = rate_dict:get(ids_key) or ""
            local marker   = "|" .. tostring(id_val) .. "|"

            if not ids_seen:find(marker, 1, true) then
                local new_ids = ids_seen .. marker
                if #new_ids < 256 then
                    rate_dict:set(ids_key, new_ids, 60)
                end
                ids_seen = new_ids
            end

            local _, distinct = ids_seen:gsub("|[^|]+|", "")

            ngx.log(ngx.INFO, string.format(
                "[WAF:IDOR] ip=%s uri=%s id=%s distinct_ids=%d req_count=%d",
                ip, uri, tostring(id_val), distinct, count))

            if distinct > idor_distinct_limit or count > idor_limit then
                block_dict:set(ip, "IDOR_ENUMERATION", idor_block_time)
                block(403, "IDOR_ENUMERATION",
                    string.format(
                        "Enumeracao de IDs detectada: %d IDs distintos em %d requisicoes (limites: %d IDs / %d req)",
                        distinct, count, idor_distinct_limit, idor_limit))
            end
        end
    end
end

-- ============================================================
-- REGRA 6: Path Traversal e Acesso a Arquivos Sensiveis (A01)
-- ============================================================
if is_rule_active("PATH_TRAVERSAL") then
    local uri_lower    = uri:lower()
    local full_request = (uri .. "?" .. qs):lower()

    -- 1. Deteccao de Path Traversal
    if full_request:find("../", 1, true) or
       full_request:find("..\\", 1, true) or
       full_request:find("%2e%2e", 1, true) or
       full_request:find("..%2f", 1, true) or
       full_request:find("..%5c", 1, true) then
        block_dict:set(ip, "PATH_TRAVERSAL", 3600)
        block(403, "PATH_TRAVERSAL", "Tentativa de Path Traversal (A01) detectada. IP adicionado a IP_BLOCKLIST.")
    end

    -- 2. Deteccao de Acesso Direto a Arquivos/Diretorios Sensiveis
    local sensitive_patterns = {
        "^/%.env",
        "^/%.git",
        "^/src/",
        "^/database/",
        "^/%.htaccess",
        "%.sql$",
        "%.bak$",
        "%.log$",
    }
    for _, pat in ipairs(sensitive_patterns) do
        if uri_lower:find(pat) then
            block_dict:set(ip, "PATH_TRAVERSAL", 3600)
            block(403, "PATH_TRAVERSAL",
                string.format("Acesso negado a arquivo sensivel (A01): '%s'. IP adicionado a IP_BLOCKLIST.", uri))
        end
    end
end

-- ============================================================
-- REGRA 7: Proteção contra Session Fixation (A07 — Virtual Patching)
-- Se ativada, remove o cookie PHPSESSID pre-existente no POST /login.php
-- forcando o PHP a criar uma nova sessao limpa e segura no login.
-- ============================================================
if is_rule_active("SESSION_FIXATION_PROTECTION") and method == "POST" and uri == "/login.php" then
    local cookie_hdr = ngx.var.http_cookie
    if cookie_hdr then
        local new_cookie = cookie_hdr:gsub("PHPSESSID=[^;%s]+;?", ""):gsub("^%s*;%s*", ""):gsub("%s*;%s*$", "")
        ngx.req.set_header("Cookie", new_cookie ~= "" and new_cookie or nil)
        ngx.log(ngx.WARN, "[WAF:SESSION_FIXATION] Cookie de sessao pre-login removido no WAF para evitar Session Fixation.")
    end
end

-- Sem bloqueio: passa para o proxy
ngx.log(ngx.INFO, string.format("[WAF:PASS] ip=%s uri=%s", ip, uri))
