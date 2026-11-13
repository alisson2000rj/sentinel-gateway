#!/bin/bash
# ============================================================
# deploy.sh — Sincroniza arquivos do host para os containers
# Uso: ./deploy.sh [arquivo]   → deploy de um arquivo específico
#      ./deploy.sh             → deploy completo de tudo
# ============================================================

set -e

WEB_CONTAINER="owasp-lab-vunlbox-lab"
GW_CONTAINER="owasp-lab-sentinel-gateway"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

verify_and_copy() {
    local src="$1"
    local dest_container="$2"
    local dest_path="$3"

    # Verifica se o arquivo existe e não está vazio
    if [ ! -f "$src" ]; then
        echo -e "${RED}[ERRO]${NC} Arquivo não encontrado: $src"
        return 1
    fi

    local size
    size=$(wc -c < "$src")
    if [ "$size" -eq 0 ]; then
        echo -e "${RED}[ERRO]${NC} Arquivo vazio (0 bytes): $src — deploy abortado!"
        return 1
    fi

    local lines
    lines=$(wc -l < "$src")
    echo -e "${YELLOW}[CHECK]${NC} $src → ${lines} linhas, ${size} bytes"

    # Copia para o container
    docker cp "$src" "${dest_container}:${dest_path}"
    echo -e "${GREEN}[OK]${NC} Copiado para ${dest_container}:${dest_path}"
}

deploy_web() {
    echo ""
    echo "=== Deploy: Aplicação Web ==="
    for f in "$PROJECT_DIR"/public/*.php; do
        verify_and_copy "$f" "$WEB_CONTAINER" "/var/www/html/public/$(basename "$f")"
    done
    for f in "$PROJECT_DIR"/public/partials/*.php; do
        verify_and_copy "$f" "$WEB_CONTAINER" "/var/www/html/public/partials/$(basename "$f")"
    done
    for f in "$PROJECT_DIR"/public/admin/*.php; do
        verify_and_copy "$f" "$WEB_CONTAINER" "/var/www/html/public/admin/$(basename "$f")"
    done
    for f in "$PROJECT_DIR"/src/*.php; do
        verify_and_copy "$f" "$WEB_CONTAINER" "/var/www/html/src/$(basename "$f")"
    done
}

deploy_gateway() {
    echo ""
    echo "=== Deploy: Gateway WAF ==="
    verify_and_copy "$PROJECT_DIR/gateway/waf/rules.lua" "$GW_CONTAINER" "/etc/gateway/waf/rules.lua"
    echo -e "${YELLOW}[INFO]${NC} Recarregando nginx..."
    docker exec "$GW_CONTAINER" openresty -s reload
    echo -e "${GREEN}[OK]${NC} Nginx recarregado."
}

# Deploy de arquivo específico
if [ -n "$1" ]; then
    src="$1"
    if [[ "$src" == *"rules.lua"* ]]; then
        verify_and_copy "$src" "$GW_CONTAINER" "/etc/gateway/waf/rules.lua"
        docker exec "$GW_CONTAINER" openresty -s reload
        echo -e "${GREEN}[OK]${NC} Nginx recarregado."
    elif [[ "$src" == *"/public/"* ]] || [[ "$src" == *"/src/"* ]]; then
        rel="${src#$PROJECT_DIR/}"
        verify_and_copy "$src" "$WEB_CONTAINER" "/var/www/html/$rel"
    else
        echo -e "${RED}[ERRO]${NC} Não sei para qual container copiar: $src"
        exit 1
    fi
    exit 0
fi

# Deploy completo
deploy_web
deploy_gateway

echo ""
echo -e "${GREEN}=== Deploy completo! ===${NC}"
