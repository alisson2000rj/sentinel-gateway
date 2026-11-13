#!/usr/bin/env bash
# ============================================================
# Vulnbox Lab — Ataque: Escalada Vertical de Privilégio (A01)
# Acessa /admin/ como usuário comum (role=user)
# ============================================================

TARGET="${TARGET:-http://owasp-lab-sentinel-gateway}"
USERNAME="user1"
PASSWORD="123456"

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
CYN='\033[0;36m'; BLD='\033[1m'; RST='\033[0m'

echo -e "\n${BLD}${CYN}════════════════════════════════════════════════${RST}"
echo -e "${BLD}  🔴 ATAQUE: Escalada Vertical — OWASP A01${RST}"
echo -e "${CYN}════════════════════════════════════════════════${RST}"
echo -e "  Alvo    : ${TARGET}/admin/*"
echo -e "  Usuário : ${USERNAME} (role=user, NÃO é admin)"
echo -e "${CYN}────────────────────────────────────────────────${RST}\n"

# Login como usuário comum
echo -e "  ${YLW}[1/2] Fazendo login como usuário comum (${USERNAME})...${RST}"
COOKIE_JAR=$(mktemp /tmp/kali_cookies_XXXXXX.txt)

curl -s -o /dev/null \
    -X POST "${TARGET}/login.php" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=${USERNAME}&password=${PASSWORD}" \
    -c "$COOKIE_JAR" \
    -L --max-time 10 2>/dev/null

echo -e "  ${GRN}Logado como ${USERNAME} (role=user).${RST}\n"

# Tentativas de acesso a rotas admin
echo -e "  ${YLW}[2/2] Tentando acessar rotas administrativas...${RST}"
echo ""

ADMIN_ROUTES=(
    "/admin/"
    "/admin/users.php"
    "/admin/logs.php"
    "/admin/settings.php"
)

BLOCKED_WAF=0
BLOCKED_APP=0
ACCESSIBLE=0

for ROUTE in "${ADMIN_ROUTES[@]}"; do
    RESP=$(curl -s -w "\n%{http_code}" \
        -b "$COOKIE_JAR" \
        "${TARGET}${ROUTE}" \
        -L --max-time 5 2>/dev/null)

    HTTP_CODE=$(echo "$RESP" | tail -1)
    BODY=$(echo "$RESP" | head -n -1)

    if [ "$HTTP_CODE" = "403" ]; then
        if echo "$BODY" | grep -qi "WAF\|Sentinel Gateway\|gateway"; then
            echo -e "  ${ROUTE} → ${RED}HTTP 403 — BLOQUEADO PELO WAF 🛡️${RST}"
            BLOCKED_WAF=$((BLOCKED_WAF + 1))
        else
            echo -e "  ${ROUTE} → ${GRN}HTTP 403 — App negou (corrigido) ✅${RST}"
            BLOCKED_APP=$((BLOCKED_APP + 1))
        fi
    elif [ "$HTTP_CODE" = "200" ]; then
        if echo "$BODY" | grep -qi "admin\|usuários\|logs\|configurações"; then
            echo -e "  ${ROUTE} → ${RED}HTTP 200 — VULNERÁVEL: ACESSO CONCEDIDO ⚠️${RST}"
            ACCESSIBLE=$((ACCESSIBLE + 1))
        else
            # Pode ter redirecionado para dashboard
            echo -e "  ${ROUTE} → HTTP 200 (verificar redirecionamento)"
        fi
    elif [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
        echo -e "  ${ROUTE} → ${GRN}HTTP ${HTTP_CODE} — Redirecionado (corrigido) ✅${RST}"
        BLOCKED_APP=$((BLOCKED_APP + 1))
    else
        echo -e "  ${ROUTE} → HTTP ${HTTP_CODE}"
    fi
    sleep 0.5
done

rm -f "$COOKIE_JAR"

echo ""
echo -e "${CYN}────────────────────────────────────────────────${RST}"
if [ $BLOCKED_WAF -gt 0 ]; then
    echo -e "  ${GRN}${BLD}RESULTADO: WAF bloqueou ${BLOCKED_WAF} tentativas 🛡️${RST}"
elif [ $ACCESSIBLE -gt 0 ]; then
    echo -e "  ${RED}${BLD}RESULTADO: VULNERÁVEL — ${ACCESSIBLE} rota(s) admin acessíveis ⚠️${RST}"
    echo -e "  Escalada vertical possível: usuário comum acessa área admin"
else
    echo -e "  ${GRN}${BLD}RESULTADO: App negou todos os acessos admin ✅${RST}"
fi
echo -e "${CYN}════════════════════════════════════════════════${RST}\n"

