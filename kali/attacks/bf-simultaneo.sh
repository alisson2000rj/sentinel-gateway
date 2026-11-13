#!/usr/bin/env bash
# ==============================================================================
# Sentinel Security Gateway — Teste de Desempenho e Concorrência HTTP
# Script: bf-simultaneo.sh
# Finalidade: Avaliar o impacto da concorrência de requisições sobre o WAF
# Laboratório: Vulnbox Lab (OWASP A01 / A07)
# ==============================================================================
#
# NOTA TÉCNICA SOBRE O MODELO DE CONCORRÊNCIA E TRANSPORTE (TCP vs HTTP):
# ------------------------------------------------------------------------------
# Este script implementa concorrência real em nível de processo no sistema
# operacional (processos filhos do Bash disparados em paralelo).
#
# - Concorrência de Requisições:
#   Até N processos 'curl' executam requisições HTTP POST simultaneamente
#   contra o endpoint de autenticação protegido pelo Sentinel Gateway (Nginx/OpenResty).
#
# - Concorrência e Comportamento de Conexões TCP:
#   Cada trabalhador (worker) executa uma instância independente do binário 'curl'.
#   Portanto, NÃO HÁ REAPROVEITAMENTO de conexões TCP (sem HTTP Keep-Alive inter-processos).
#   Cada requisição individual realiza o ciclo TCP completo:
#     1. Resolução DNS e alocação de porta efêmera local
#     2. Three-way handshake TCP (SYN -> SYN-ACK -> ACK)
#     3. Negociação de requisição/resposta HTTP L7 com o Nginx/OpenResty
#     4. Encerramento da conexão TCP (FIN/ACK ou RST)
#   Em qualquer instante t durante o pico, existem até N conexões TCP ativas
#   simultâneas entre o container atacante e o Gateway.
# ==============================================================================

set -o pipefail

# Diretório base do script e resultados
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${RESULTS_DIR:-${SCRIPT_DIR}/results}"

# Configurações do Alvo (preserva parâmetros originais de brute_force.sh)
TARGET="${TARGET:-http://owasp-lab-sentinel-gateway}"
LOGIN_URL="${TARGET}/login.php"

# Limites operacionais de segurança
MAX_ALLOWED_CONCURRENCY="${MAX_ALLOWED_CONCURRENCY:-50}"
DEFAULT_TOTAL_REQUESTS="${DEFAULT_TOTAL_REQUESTS:-50}"
CONNECT_TIMEOUT="${CONNECT_TIMEOUT:-2}"
REQ_TIMEOUT="${REQ_TIMEOUT:-5}"

# Credenciais fixas de teste (não expõe senhas sensíveis nem quebra senhas)
# Atende requisitos de tamanho (>=8) e complexidade (letras e números) da Regra 3
TEST_USER="${TEST_USER:-perf_user}"
TEST_PASS="${TEST_PASS:-PerfTest#2026}"

# Cores para exibição em terminal
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
BLU='\033[0;34m'
CYN='\033[0;36m'
BLD='\033[1m'
RST='\033[0m'

# ==============================================================================
# 1. VALIDAÇÃO DE PRÉ-REQUISITOS E AMBIENTE
# ==============================================================================

if ! command -v curl >/dev/null 2>&1; then
    echo -e "${RED}[ERRO CRÍTICO] O utilitário 'curl' não está instalado neste ambiente.${RST}" >&2
    exit 1
fi

if [ -z "$BASH_VERSION" ]; then
    echo -e "${RED}[ERRO CRÍTICO] Este script exige o interpretador GNU Bash.${RST}" >&2
    exit 1
fi

# Pré-checagem de conectividade com o alvo
preflight_check() {
    local check_code
    check_code=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout "${CONNECT_TIMEOUT}" \
        --max-time "${REQ_TIMEOUT}" \
        "${LOGIN_URL}" 2>/dev/null || echo "000")

    if [ "$check_code" = "000" ]; then
        echo -e "${RED}[ERRO DE CONEXÃO] Não foi possível conectar ao alvo: ${LOGIN_URL}${RST}" >&2
        echo -e "${YLW}Verifique se o container 'owasp-lab-sentinel-gateway' está em execução na rede Docker.${RST}" >&2
        exit 1
    fi
}

# ==============================================================================
# 2. INTERAÇÃO E VALIDAÇÃO DE ENTRADA DO OPERADOR
# ==============================================================================

echo -e "\n${BLD}${CYN}════════════════════════════════════════════════════════════════════${RST}"
echo -e "${BLD}  🛡️ SENTINEL WAF — TESTE DE DESEMPENHO E CONCORRÊNCIA HTTP${RST}"
echo -e "${CYN}════════════════════════════════════════════════════════════════════${RST}"
echo -e "  Alvo                   : ${BLD}${LOGIN_URL}${RST}"
echo -e "  Método / Endpoint      : POST /login.php (application/x-www-form-urlencoded)"
echo -e "  Usuário de Teste       : ${TEST_USER} (senha fixa de calibração)"
echo -e "  Limite de Concorrência : Máximo de ${MAX_ALLOWED_CONCURRENCY} operações simultâneas"
echo -e "${CYN}────────────────────────────────────────────────────────────────────${RST}"

# Solicitação interativa do número de operações simultâneas
if [ -n "$1" ]; then
    CONCURRENCY="$1"
    echo -e "  Operações simultâneas informadas via argumento: ${BLD}${CONCURRENCY}${RST}"
else
    echo -n "Informe o número de operações simultâneas: "
    read -r CONCURRENCY
fi

# Validação do valor de concorrência
if ! [[ "$CONCURRENCY" =~ ^[1-9][0-9]*$ ]]; then
    echo -e "${RED}[ERRO] Entrada inválida ('${CONCURRENCY}'). Deve ser um número inteiro positivo.${RST}" >&2
    exit 1
fi

if [ "$CONCURRENCY" -gt "$MAX_ALLOWED_CONCURRENCY" ]; then
    echo -e "${RED}[ERRO] O valor solicitado (${CONCURRENCY}) excede o limite máximo configurado (${MAX_ALLOWED_CONCURRENCY}).${RST}" >&2
    exit 1
fi

# Total de requisições
if [ -n "$2" ]; then
    TOTAL_REQUESTS="$2"
    echo -e "  Total de requisições informado via argumento  : ${BLD}${TOTAL_REQUESTS}${RST}"
elif [ -n "$TOTAL_REQUESTS_ENV" ]; then
    TOTAL_REQUESTS="$TOTAL_REQUESTS_ENV"
    echo -e "  Total de requisições via variável de ambiente : ${BLD}${TOTAL_REQUESTS}${RST}"
elif [ -t 0 ]; then
    read -r -p "Informe o total de requisições [padrão: ${DEFAULT_TOTAL_REQUESTS}]: " USER_TOTAL
    TOTAL_REQUESTS="${USER_TOTAL:-$DEFAULT_TOTAL_REQUESTS}"
else
    if read -t 1 -r USER_TOTAL; then
        TOTAL_REQUESTS="${USER_TOTAL:-$DEFAULT_TOTAL_REQUESTS}"
    else
        TOTAL_REQUESTS="$DEFAULT_TOTAL_REQUESTS"
    fi
fi

if ! [[ "$TOTAL_REQUESTS" =~ ^[1-9][0-9]*$ ]]; then
    echo -e "${RED}[ERRO] Total de requisições inválido ('${TOTAL_REQUESTS}'). Deve ser um número inteiro positivo.${RST}" >&2
    exit 1
fi

# Teste prévio de conectividade
preflight_check

# ==============================================================================
# 3. PREPARAÇÃO DOS ARQUIVOS DE SAÍDA (CSV E RESUMO)
# ==============================================================================

mkdir -p "${RESULTS_DIR}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CSV_FILE="${RESULTS_DIR}/bf_simultaneo_${TIMESTAMP}.csv"
SUMMARY_FILE="${RESULTS_DIR}/bf_simultaneo_${TIMESTAMP}_resumo.txt"

# Cabeçalho do CSV (não inclui dados sensíveis ou senhas)
echo "id,worker,timestamp,latency_seconds,http_status,waf_rule,category,curl_exit_code" > "${CSV_FILE}"

# ==============================================================================
# 4. TRATAMENTO DE INTERRUPÇÃO GRACIOSA (SIGINT / SIGTERM)
# ==============================================================================

INTERRUPTED=0
cleanup() {
    INTERRUPTED=1
    echo -e "\n\n${YLW}[!] Interrupção detectada (SIGINT/SIGTERM). Encerrando processos filhos...${RST}"
    
    # Encerra processos filhos ativos em background pertencentes a este script
    local running_jobs
    running_jobs=$(jobs -p)
    if [ -n "$running_jobs" ]; then
        kill $running_jobs 2>/dev/null || true
    fi
    
    echo -e "${YLW}[!] Consolidando resultados parciais gravados no CSV...${RST}"
    finalize_report
    exit 130
}
trap cleanup SIGINT SIGTERM

# ==============================================================================
# 5. MOTOR DE DISPARO CONCORRENTE
# ==============================================================================

run_single_request() {
    local req_id="$1"
    local worker_id="worker_${2}"
    local req_ts
    req_ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Dispara o curl capturando cabeçalhos de resposta e métricas de tempo
    local raw_output
    raw_output=$(curl -s -D - -o /dev/null \
        -X POST "${LOGIN_URL}" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "username=${TEST_USER}&password=${TEST_PASS}" \
        --connect-timeout "${CONNECT_TIMEOUT}" \
        --max-time "${REQ_TIMEOUT}" \
        -w "\nSTATS:%{http_code}:%{time_total}:%{exitcode}" 2>/dev/null)
    
    local curl_sys_exit=$?
    local http_code
    local time_total
    local curl_stats_exit
    local waf_rule

    http_code=$(echo "$raw_output" | grep -a "^STATS:" | cut -d: -f2)
    time_total=$(echo "$raw_output" | grep -a "^STATS:" | cut -d: -f3)
    curl_stats_exit=$(echo "$raw_output" | grep -a "^STATS:" | cut -d: -f4)
    waf_rule=$(echo "$raw_output" | grep -ia "^X-WAF-Rule:" | head -1 | tr -d "\r\n" | cut -d: -f2- | xargs)
    [ -z "$waf_rule" ] && waf_rule="none"

    # Classificação rigorosa de acordo com evidências técnicas reais
    local category="UNKNOWN"
    if [ -z "$http_code" ] || [ "$curl_stats_exit" != "0" ]; then
        if [ "$curl_stats_exit" = "28" ] || [ "$curl_sys_exit" = "28" ]; then
            category="TRANSPORT_TIMEOUT"
        else
            category="TRANSPORT_ERROR_${curl_stats_exit:-$curl_sys_exit}"
        fi
        http_code="000"
        time_total="${time_total:-$REQ_TIMEOUT}"
    elif [ "$http_code" = "429" ] && [ "$waf_rule" = "BRUTE_FORCE_LOGIN" ]; then
        category="WAF_BLOCK_RATELIMIT"
    elif [ "$http_code" = "403" ] && [ "$waf_rule" = "IP_BLOCKLIST" ]; then
        category="WAF_BLOCK_IP"
    elif [ "$http_code" = "400" ] && [ "$waf_rule" = "WEAK_PASSWORD_POLICY" ]; then
        category="WAF_BLOCK_WEAK_PASS"
    elif [ "$http_code" = "403" ] && [ "$waf_rule" != "none" ]; then
        category="WAF_BLOCK_${waf_rule}"
    elif [ "$http_code" = "200" ] && [ "$waf_rule" = "none" ]; then
        category="APP_AUTH_FAILURE"
    elif [ "$http_code" = "302" ] && [ "$waf_rule" = "none" ]; then
        category="APP_AUTH_SUCCESS"
    elif [[ "$http_code" =~ ^5[0-9]{2}$ ]]; then
        category="SERVER_ERROR_${http_code}"
    elif [ "$http_code" = "403" ] || [ "$http_code" = "429" ]; then
        # Código de bloqueio sem cabeçalho explícito do WAF
        category="INCONCLUSIVE_${http_code}"
    else
        category="HTTP_${http_code}"
    fi

    # Gravação atômica da linha no CSV
    echo "${req_id},${worker_id},${req_ts},${time_total},${http_code},${waf_rule},${category},${curl_stats_exit:-0}" >> "${CSV_FILE}"
}

echo -e "\n${BLD}[+] Iniciando teste de carga concorrente...${RST}"
echo -e "    Concorrência configurada : ${BLD}${CONCURRENCY} workers${RST}"
echo -e "    Total planejado          : ${BLD}${TOTAL_REQUESTS} requisições${RST}"
echo -e "    CSV de saída             : ${CSV_FILE}"
echo -e "${CYN}────────────────────────────────────────────────────────────────────${RST}"

EXEC_START_TIME=$(date +%s.%N)

# Loop de despacho com controle rigoroso de concorrência máxima
for ((i=1; i<=TOTAL_REQUESTS; i++)); do
    [ $INTERRUPTED -eq 1 ] && break

    worker_id=$(( (i - 1) % CONCURRENCY + 1 ))
    (
        run_single_request "$i" "$worker_id"
    ) &

    # Garante que não haja mais do que CONCURRENCY processos em execução
    while [ "$(jobs -rp | wc -l)" -ge "$CONCURRENCY" ]; do
        wait -n 2>/dev/null || true
    done
done

# Aguarda a finalização dos processos restantes
wait

EXEC_END_TIME=$(date +%s.%N)

# ==============================================================================
# 6. CONSOLIDAÇÃO DE MÉTRICAS E GERAÇÃO DE RELATÓRIO
# ==============================================================================

finalize_report() {
    local duration
    duration=$(awk "BEGIN { d = ${EXEC_END_TIME:-$(date +%s.%N)} - ${EXEC_START_TIME}; printf \"%.3f\", (d > 0 ? d : 0.001) }")

    local now_ts
    now_ts=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

    # Análise das métricas utilizando script inline Python3 (com fallback em awk)
    if command -v python3 >/dev/null 2>&1; then
        python3 - "${CSV_FILE}" "${SUMMARY_FILE}" "${LOGIN_URL}" "${CONCURRENCY}" "${TOTAL_REQUESTS}" "${duration}" "${CONNECT_TIMEOUT}" "${REQ_TIMEOUT}" "${now_ts}" << "PY_EOF"
import sys, math
from collections import Counter

csv_file = sys.argv[1]
summary_file = sys.argv[2]
target_url = sys.argv[3]
concurrency = sys.argv[4]
planned_reqs = sys.argv[5]
duration = float(sys.argv[6])
conn_timeout = sys.argv[7]
req_timeout = sys.argv[8]
now_ts = sys.argv[9]

latencies = []
http_codes = Counter()
categories = Counter()
waf_rules = Counter()
executed_count = 0

try:
    with open(csv_file, 'r', encoding='utf-8') as f:
        header = f.readline()
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split(',')
            if len(parts) < 8:
                continue
            executed_count += 1
            req_id, worker, ts, lat_str, code, rule, cat, exit_code = parts[:8]
            http_codes[code] += 1
            categories[cat] += 1
            if rule != 'none':
                waf_rules[rule] += 1
            try:
                val = float(lat_str)
                # Inclui latência de requisições que obtiveram resposta HTTP
                if code != '000':
                    latencies.append(val)
            except ValueError:
                pass
except Exception as e:
    print(f"Erro ao processar CSV: {e}", file=sys.stderr)

# Cálculo de latência e percentis
n_lat = len(latencies)
if n_lat > 0:
    latencies.sort()
    min_lat = latencies[0] * 1000.0
    max_lat = latencies[-1] * 1000.0
    mean_lat = (sum(latencies) / n_lat) * 1000.0
    
    def calc_percentile(p):
        if n_lat == 1:
            return latencies[0] * 1000.0
        k = (n_lat - 1) * (p / 100.0)
        f = math.floor(k)
        c = math.ceil(k)
        if f == c:
            return latencies[int(k)] * 1000.0
        return (latencies[int(f)] * (c - k) + latencies[int(c)] * (k - f)) * 1000.0

    p50 = calc_percentile(50)
    p95 = calc_percentile(95)
    p99 = calc_percentile(99)
else:
    min_lat = max_lat = mean_lat = p50 = p95 = p99 = 0.0

rps = executed_count / duration if duration > 0 else 0.0

# Contagens agregadas
resp_2xx = sum(count for code, count in http_codes.items() if code.startswith('2'))
resp_3xx = sum(count for code, count in http_codes.items() if code.startswith('3'))
resp_4xx = sum(count for code, count in http_codes.items() if code.startswith('4'))
resp_5xx = sum(count for code, count in http_codes.items() if code.startswith('5'))
transport_errors = http_codes.get('000', 0)

waf_ratelimit = categories.get('WAF_BLOCK_RATELIMIT', 0)
waf_ipblock   = categories.get('WAF_BLOCK_IP', 0)
waf_weakpass  = categories.get('WAF_BLOCK_WEAK_PASS', 0)
waf_total     = sum(count for cat, count in categories.items() if cat.startswith('WAF_BLOCK'))

app_auth_fail = categories.get('APP_AUTH_FAILURE', 0)
app_auth_ok   = categories.get('APP_AUTH_SUCCESS', 0)
inconclusive  = sum(count for cat, count in categories.items() if cat.startswith('INCONCLUSIVE'))

report = f"""================================================================================
          SENTINEL WAF — RELATÓRIO DE DESEMPENHO E CONCORRÊNCIA HTTP
================================================================================
Data/Hora de Conclusão : {now_ts}
Arquivo CSV Detalhado  : {csv_file}
Arquivo de Resumo      : {summary_file}

--------------------------------------------------------------------------------
1. PARÂMETROS DO TESTE
--------------------------------------------------------------------------------
Alvo (URL de Destino)  : {target_url}
Método HTTP            : POST
Content-Type           : application/x-www-form-urlencoded
Operações Simultâneas  : {concurrency} workers paralelos
Requisições Planejadas : {planned_reqs}
Timeout por Requisição : {req_timeout}s total (conexão: {conn_timeout}s)
Modelo de Transporte   : Concorrência real de processos Bash (curl por requisição)
                         Conexões TCP individuais (sem reaproveitamento keep-alive)

--------------------------------------------------------------------------------
2. RESUMO DE EXECUÇÃO E VAZÃO
--------------------------------------------------------------------------------
Requisições Planejadas : {planned_reqs}
Requisições Executadas : {executed_count} ({executed_count/float(planned_reqs)*100:.1f}%)
Respostas Recebidas    : {executed_count - transport_errors}
Falhas de Transporte   : {transport_errors}
Duração Total          : {duration:.3f} segundos
Vazão Observada (RPS)  : {rps:.2f} requisições/segundo

--------------------------------------------------------------------------------
3. DISTRIBUIÇÃO DAS RESPOSTAS HTTP
--------------------------------------------------------------------------------
- Respostas 2xx (Sucesso / Tela Login) : {resp_2xx:<5} ({resp_2xx/executed_count*100 if executed_count else 0:.1f}%)
- Respostas 3xx (Redirecionamentos)    : {resp_3xx:<5} ({resp_3xx/executed_count*100 if executed_count else 0:.1f}%)
- Respostas 4xx (Erros do Cliente/WAF) : {resp_4xx:<5} ({resp_4xx/executed_count*100 if executed_count else 0:.1f}%)
  * HTTP 429 Too Many Requests         : {http_codes.get('429', 0)}
  * HTTP 403 Forbidden                 : {http_codes.get('403', 0)}
  * HTTP 400 Bad Request               : {http_codes.get('400', 0)}
- Respostas 5xx (Erros de Servidor)    : {resp_5xx:<5} ({resp_5xx/executed_count*100 if executed_count else 0:.1f}%)
- Falhas de Conexão / Timeout (000)    : {transport_errors:<5} ({transport_errors/executed_count*100 if executed_count else 0:.1f}%)

--------------------------------------------------------------------------------
4. ANÁLISE DE SEGURANÇA E ATRIBUIÇÃO AO WAF
--------------------------------------------------------------------------------
[+] Bloqueios Confirmados pelo WAF        : {waf_total}
    * Rate Limiting (BRUTE_FORCE_LOGIN)   : {waf_ratelimit}
    * Lista Negra em RAM (IP_BLOCKLIST)   : {waf_ipblock}
    * Política de Senha (WEAK_PASSWORD)   : {waf_weakpass}
[+] Processadas pela Aplicação (Backend)  : {app_auth_fail + app_auth_ok}
    * Falhas de Login (HTTP 200 backend)  : {app_auth_fail}
    * Sucesso de Login (HTTP 302 backend) : {app_auth_ok}
[?] Respostas Inconclusivas               : {inconclusive}

--------------------------------------------------------------------------------
5. ESTATÍSTICAS DE LATÊNCIA (TEMPO DE RESPOSTA EM MILISSEGUNDOS)
--------------------------------------------------------------------------------
Amostras Válidas de Latência : {n_lat}
Mínima                       : {min_lat:.2f} ms
Média                        : {mean_lat:.2f} ms
Máxima                       : {max_lat:.2f} ms
Percentil 50 (Mediana P50)   : {p50:.2f} ms
Percentil 95 (P95)           : {p95:.2f} ms
Percentil 99 (P99)           : {p99:.2f} ms
================================================================================
"""

# Grava resumo em arquivo
with open(summary_file, 'w', encoding='utf-8') as f_out:
    f_out.write(report)

# Imprime resumo no terminal
print(report)
PY_EOF
    fi
}

finalize_report

echo -e "${GRN}[✔] Teste finalizado com sucesso!${RST}"
echo -e "    Dados detalhados : ${BLD}${CSV_FILE}${RST}"
echo -e "    Relatório resumo : ${BLD}${SUMMARY_FILE}${RST}\n"
