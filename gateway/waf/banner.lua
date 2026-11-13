-- ============================================================
-- Sentinel Security Gateway — Banner WAF (body_filter_by_lua)
-- Injeta um banner fixo no topo de toda resposta HTML
-- ============================================================

-- Só processa respostas HTML
local ct = ngx.header["Content-Type"] or ""
if not ct:lower():find("text/html", 1, true) then
    return
end

local chunk = ngx.arg[1]
if not chunk or #chunk == 0 then
    return
end

-- Só injeta se o chunk contiver a tag <body>
if not chunk:lower():find("<body", 1, true) then
    return
end

local mode     = ngx.shared.waf_mode:get("mode") or "active"
local is_active = (mode == "active")

local label      = is_active and "Ativado"   or "Desativado"
local icon       = is_active and "🟢"        or "🟠"
local bg         = is_active and "#0d2b0d"   or "#2b1a00"
local border_clr = is_active and "#3fb950"   or "#ffa500"
local text_clr   = is_active and "#3fb950"   or "#ffa500"
local btn_bg     = is_active and "#238636"   or "#d97706"
local action     = "/_gateway/ui/toggle"
local desc       = is_active
    and "bloqueando brute-force, IDOR, scanners e SQLi"
    or  "proxy puro — vulnerabilidades expostas ao atacante"

local client_ip  = ngx.var.remote_addr or "127.0.0.1"

local banner = string.format([[
<div id="gw-banner" style="
  position:fixed;top:0;left:0;right:0;z-index:99999;
  background:%s;border-bottom:2px solid %s;
  padding:7px 20px;display:flex;align-items:center;
  justify-content:space-between;font-family:monospace;
  font-size:13px;box-shadow:0 2px 8px rgba(0,0,0,.5);
">
  <span style="color:#c9d1d9">
    🛡️ <strong style="color:#58a6ff">Sentinel Gateway</strong>
    &nbsp;|&nbsp;
    IP Origem: <strong style="color:#58a6ff">%s</strong>
    &nbsp;|&nbsp;
    Status: <strong style="color:%s">%s %s</strong>
    &nbsp;<span style="color:#6e7681;font-size:11px">(%s)</span>
  </span>
  <form method="POST" action="%s" style="margin:0">
    <button type="submit" style="
      background:%s;border:none;
      color:#ffffff;padding:5px 18px;border-radius:20px;
      cursor:pointer;font-family:monospace;font-size:12px;
      font-weight:bold;transition:all .2s;
    ">%s WAF %s</button>
  </form>
</div>
<div style="height:42px"></div>
]], bg, border_clr, client_ip, text_clr, icon, label, desc, action,
    btn_bg, icon, label)

-- Se o HTML não tiver <meta charset...>, injeta no <head> para garantir a acentuação e emojis
if not chunk:lower():find("charset", 1, true) and chunk:lower():find("<head", 1, true) then
    chunk = chunk:gsub(
        "(<[Hh][Ee][Aa][Dd][^>]*>)",
        "%1\n<meta charset=\"UTF-8\">",
        1
    )
end

-- Injeta o banner imediatamente após a tag <body ...>
local new_chunk = chunk:gsub(
    "(<[Bb][Oo][Dd][Yy][^>]*>)",
    "%1" .. banner,
    1   -- apenas primeira ocorrência
)

if new_chunk ~= chunk then
    ngx.arg[1] = new_chunk
end

