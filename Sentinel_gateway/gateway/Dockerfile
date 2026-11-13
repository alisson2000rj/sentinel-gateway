FROM openresty/openresty:alpine

# Ferramentas auxiliares
RUN apk add --no-cache curl bash net-tools

# Copia configuração nginx e módulos WAF
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY waf/       /etc/gateway/waf/

# Permissões e diretórios de log
RUN mkdir -p /var/log/nginx /var/log/gateway && \
    chmod -R 755 /etc/gateway/ && \
    chmod -R 644 /etc/gateway/waf/*.lua

EXPOSE 80

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
