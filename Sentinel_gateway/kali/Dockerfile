FROM kalilinux/kali-rolling

# Instala ferramentas de ataque
RUN apt-get update && apt-get install -y \
    curl \
    hydra \
    nikto \
    whatweb \
    python3 \
    python3-requests \
    nmap \
    dnsutils \
    net-tools \
    iputils-ping \
    nano \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Copia scripts de ataque
COPY attacks/ /attacks/
RUN chmod +x /attacks/*.sh

# Define variável padrão do alvo (nome do container gateway na rede)
ENV TARGET=http://owasp-lab-sentinel-gateway

WORKDIR /attacks

# Container efêmero — mantém vivo para exec interativo
CMD ["sleep", "infinity"]

