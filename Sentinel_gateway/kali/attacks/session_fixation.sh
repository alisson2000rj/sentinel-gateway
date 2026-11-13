#!/usr/bin/env bash
# ============================================================
# Vulnbox Lab — Ataque: Session Fixation (A07)
# Demonstra se o ID de sessão muda após o login
# ============================================================

TARGET="${TARGET:-http://owasp-lab-sentinel-gateway}"
USERNAME="user3"
PASSWORD="!@3asd!@3"

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
CYN='\033[0;36m'; BLD='\033[1m'; RST='\033[0m'

WAF_STATUS=$(curl -s "${TARGET}/_gateway/status" --max-time 3 2>/dev/null)
WAF_MODE=$(echo "$WAF_STATUS" | grep -oP '"mode":"[^"]+"' | cut -d'"' -f4)

echo -e "\n${BLD}${CYN}════════════════════════════════════════════════${RST}"
echo -e "${BLD}  🔴 ATAQUE: Session Fixation — OWASP A07${RST}"
echo -e "${CYN}════════════════════════════════════════════════${RST}"
echo -e "  Alvo    : ${TARGET}/login.php"
echo -e "  Modo WAF: ${BLD}${WAF_MODE:-desconhecido}${RST}"
echo -e "  Conceito: Se o PHPSESSID não muda após login,"
echo -e "            um atacante que conhece o ID pré-login"
echo -e "            pode sequestrar a sessão autenticada."
if [ "$WAF_MODE" = "active" ]; then
    echo -e "  ${YLW}ℹ️ WAF ATIVO: A Regra 7 (Virtual Patching) protege na borda gerando novo ID.${RST}"
    echo -e "  ${YLW}  Para testar a aplicação pura sem WAF: curl -s -X POST ${TARGET}/_gateway/deactivate${RST}"
fi
echo -e "${CYN}────────────────────────────────────────────────${RST}\n"

# Passo 1: GET /login.php — obtém PHPSESSID pré-login
echo -e "  ${YLW}[1/4] Obtendo PHPSESSID antes do login (visitante)...${RST}"
RESP_HEADERS_INIT=$(mktemp /tmp/kali_headers_XXXXXX.txt)
curl -s -D "$RESP_HEADERS_INIT" -o /dev/null \
    "${TARGET}/login.php" \
    --max-time 10 2>/dev/null

SESSION_BEFORE=$(grep -i "Set-Cookie" "$RESP_HEADERS_INIT" | grep -i "PHPSESSID" | tail -n1 | sed -E 's/.*PHPSESSID=([^;[:space:]]+).*/\1/' 2>/dev/null || echo "")
echo -e "  ${BLD}PHPSESSID antes do login:${RST} ${YLW}${SESSION_BEFORE:-'(não definido)'}${RST}"
echo ""
rm -f "$RESP_HEADERS_INIT"

# Passo 2: POST /login.php — autentica
echo -e "  ${YLW}[2/4] Fazendo login como ${USERNAME}...${RST}"
RESP_HEADERS=$(mktemp /tmp/kali_headers_XXXXXX.txt)
curl -s -D "$RESP_HEADERS" -o /dev/null \
    -X POST "${TARGET}/login.php" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=${USERNAME}&password=${PASSWORD}" \
    -b "PHPSESSID=${SESSION_BEFORE}" \
    -L --max-time 10 2>/dev/null

NEW_COOKIE=$(grep -i "Set-Cookie" "$RESP_HEADERS" | grep -i "PHPSESSID" | tail -n1 | sed -E 's/.*PHPSESSID=([^;[:space:]]+).*/\1/' 2>/dev/null || echo "")

if [ -n "$NEW_COOKIE" ]; then
    SESSION_AFTER="$NEW_COOKIE"
else
    SESSION_AFTER="$SESSION_BEFORE"
fi
echo -e "  ${BLD}PHPSESSID depois do login:${RST} ${YLW}${SESSION_AFTER:-'(não encontrado)'}${RST}"
echo ""

# Passo 3: Verificar atributos do cookie
echo -e "  ${YLW}[3/4] Verificando atributos do cookie...${RST}"
COOKIE_LINE=$(grep -i "Set-Cookie" "$RESP_HEADERS" | grep -i "PHPSESSID" | tail -n1 2>/dev/null || echo "")
if echo "$COOKIE_LINE" | grep -qi "httponly"; then
    echo -e "  HttpOnly : ${GRN}SIM ✅${RST}"
else
    echo -e "  HttpOnly : ${RED}NÃO ⚠️${RST}"
fi
if echo "$COOKIE_LINE" | grep -qi "secure"; then
    echo -e "  Secure   : ${GRN}SIM ✅${RST}"
else
    echo -e "  Secure   : ${YLW}NÃO (esperado em HTTP local)${RST}"
fi

rm -f "$RESP_HEADERS"

# Passo 4: Análise
echo ""
echo -e "  ${YLW}[4/4] Analisando resultado...${RST}"
echo ""
echo -e "${CYN}────────────────────────────────────────────────${RST}"

if [ -z "$SESSION_BEFORE" ] && [ -z "$SESSION_AFTER" ]; then
    echo -e "  ${YLW}AVISO: Não foi possível capturar cookies (WAF bloqueou?)${RST}"
elif [ "$SESSION_BEFORE" = "$SESSION_AFTER" ] && [ -n "$SESSION_BEFORE" ]; then
    echo -e "  ${RED}${BLD}RESULTADO: VULNERÁVEL — Session Fixation possível ⚠️${RST}"
    echo -e "  PHPSESSID não mudou após o login!"
    echo -e "  Um atacante que conhecia '${SESSION_BEFORE}' agora tem sessão autenticada"
elif [ -n "$SESSION_AFTER" ]; then
    if [ "$WAF_MODE" = "active" ]; then
        echo -e "  ${GRN}${BLD}RESULTADO: PROTEGIDO PELO GATEWAY (WAF ATIVO) 🛡️${RST}"
        echo -e "  O Sentinel Gateway (Regra 7 - Virtual Patching) removeu o cookie pré-login,"
        echo -e "  forçando uma nova sessão segura mesmo com a aplicação no modo vulnerável."
    else
        echo -e "  ${GRN}${BLD}RESULTADO: CORRIGIDO NA APLICAÇÃO — session_regenerate_id() aplicado ✅${RST}"
        echo -e "  PHPSESSID mudou após o login (Modo Corrigido da aplicação ativo)."
    fi
    echo -e "  Antes : ${SESSION_BEFORE:-'(sem sessão prévia)'}"
    echo -e "  Depois: ${SESSION_AFTER}"
else
    echo -e "  ${YLW}Não foi possível determinar o resultado${RST}"
fi
echo -e "${CYN}════════════════════════════════════════════════${RST}\n"

