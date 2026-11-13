# 🛡️ Vulnbox Lab

> **AVISO IMPORTANTE**
>
> ⚠️ **ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.**
>
> Utilizar exclusivamente em **ambiente controlado de laboratório**.
> **NÃO expor à Internet ou a redes de produção.**
> Não utilizar dados reais.

---

## Visão Geral

**Vulnbox Lab** é uma aplicação web propositalmente vulnerável para fins acadêmicos de cibersegurança. Demonstra vulnerabilidades do OWASP Top 10:

- **A01: Broken Access Control** — IDOR, escalada horizontal, escalada vertical
- **A07: Identification and Authentication Failures** — senhas fracas, força bruta, sessão insegura

A aplicação roda em **Docker** (PHP 8.2 + Apache + MySQL 8.0) e possui dois modos operacionais:

| Modo | `APP_MODE` | Descrição |
|------|------------|-----------|
| 🔴 Vulnerável | `vulnerable` | Falhas A01 e A07 ativas para exploração |
| 🟢 Corrigido  | `fixed`      | Mitigações implementadas para comparação |

---

## Requisitos

- Computador 64 bits com **Ubuntu 22.04+** ou **Kali Linux** atualizado
- Conexão com a Internet na primeira execução (para baixar as imagens PHP e MySQL)
- Pelo menos 4 GB de RAM livre e 5 GB de espaço em disco recomendados
- Permissão para usar `sudo` na máquina
- Docker Engine e Docker Compose v2 (`docker compose`)

> O laboratório publica a porta local `8080` através do **Sentinel Gateway**.
> `web` e `mysql` não são mais acessíveis diretamente do host.
> Não o exponha à Internet ou a uma rede de produção.

---

## 🛡️ Sentinel Gateway

O ambiente inclui um **Sentinel Gateway** (nginx + WAF Lua) posicionado entre a máquina atacante e a aplicação:

```
[kali-attacker] ── frontend-net ──▶ [owasp-lab-sentinel-gateway:8080] ── backend-net ──▶ [web + mysql]
```

### Controle rápido

```bash
# Ver status do WAF
curl -s http://localhost:8080/_gateway/status

# Ativar WAF (bloqueia ataques)
curl -s -X POST http://localhost:8080/_gateway/activate

# Desativar WAF (proxy puro — expõe vulnerabilidades)
curl -s -X POST http://localhost:8080/_gateway/deactivate

# Limpar bloqueios após testes
curl -s -X POST http://localhost:8080/_gateway/reset
```

### Máquina Kali Attacker

```bash
# Entrar no terminal do Kali
docker exec -it kali-attacker bash

# Executar todos os ataques
docker exec kali-attacker bash /attacks/run_all.sh
```

> Documentação completa: [`docs/GATEWAY.md`](docs/GATEWAY.md)

---

## Instalação do Docker no Linux

Execute **somente uma** das seções seguintes, de acordo com seu sistema
operacional. Ao final, confirme que os comandos `docker --version` e
`docker compose version` funcionam.

### Ubuntu 22.04, 24.04 ou posterior

Os comandos abaixo instalam o Docker Engine e o Compose v2 a partir do
repositório oficial do Docker:

```bash
# Atualiza o sistema e instala os pré-requisitos
sudo apt update
sudo apt install -y ca-certificates curl

# Adiciona a chave e o repositório oficial do Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Instala Docker Engine, Buildx e Docker Compose v2
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Se já houver uma instalação antiga do Docker e o `apt` informar conflito de
pacotes, consulte a lista de pacotes a remover na
[documentação oficial do Docker para Ubuntu](https://docs.docker.com/engine/install/ubuntu/).

### Kali Linux

No Kali, instale os pacotes da própria distribuição:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
```

Se o pacote `docker-compose-v2` não estiver disponível na sua versão do Kali,
instale o plugin com `sudo apt install -y docker-compose-plugin` e execute a
verificação abaixo. A documentação do Kali também descreve a instalação do
Docker em: [Installing Docker on Kali Linux](https://www.kali.org/docs/containers/installing-docker-on-kali/).

### Permitir uso sem `sudo` (opcional)

Por padrão, talvez seja necessário prefixar todos os comandos Docker com
`sudo`. Para usar Docker com seu usuário atual:

```bash
sudo usermod -aG docker $USER
```

Encerre a sessão e entre novamente (ou reinicie o computador). Em seguida,
verifique a instalação:

```bash
docker --version
docker compose version
docker run --rm hello-world
```

> Atenção: integrar um usuário ao grupo `docker` concede privilégios
> equivalentes a administrador na máquina. Em computadores compartilhados,
> prefira usar `sudo docker ...`.

---

## Instalação e Execução

```bash
# 1. Extraia o arquivo .zip recebido e entre na pasta criada
# Exemplo: unzip vulnbox-lab.zip
cd vulnbox-lab

# 2. Confira se o arquivo .env foi extraído junto com o projeto
test -f .env || { echo "Erro: o arquivo .env não foi encontrado no ZIP."; exit 1; }

# 3. Informe o usuário local ao build (permite ao banner atualizar .env)
export HOST_UID=$(id -u)
export HOST_GID=$(id -g)

# 4. Suba o ambiente (o modo inicial é o definido em .env)
docker compose up -d --build

# 5. Confirme que os dois serviços estão em execução
docker compose ps
```

Espere o MySQL ficar com o estado `healthy` (normalmente até 30 segundos) e
acesse [http://localhost:8080](http://localhost:8080). Use `admin / admin123`
ou outra credencial de laboratório listada abaixo.

Se você optou por não entrar no grupo `docker`, substitua `docker compose` por
`sudo docker compose` nos comandos deste README. Nesse caso, preserve os IDs
do seu usuário no build, por exemplo:

```bash
sudo HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose up -d --build
```

### Comandos úteis

```bash
# Acompanhar a inicialização e erros do serviço web
docker compose logs -f web

# Parar os serviços sem apagar os dados
docker compose down

# Reiniciar tudo do zero, apagando o banco de dados do laboratório
docker compose down -v
docker compose up -d --build
```

### Problemas comuns

| Sintoma | Solução |
|---------|---------|
| `permission denied` ao executar Docker | Faça logout/login após `usermod -aG docker $USER`, ou use `sudo docker compose ...`. |
| `docker: 'compose' is not a docker command` | Instale o Compose v2 conforme a seção do seu sistema e confirme com `docker compose version`. |
| Porta `8080` ou `3306` já está em uso | Pare o serviço que usa a porta ou altere o mapeamento correspondente em `docker-compose.yml`. |
| MySQL ainda não está pronto | Execute `docker compose ps` e `docker compose logs -f mysql`; aguarde o estado `healthy`. |
| Dados de testes alterados ou contas bloqueadas | Execute `docker compose down -v` e depois `docker compose up -d --build` para recriar a base. |

### Alternar entre modos

Clique no banner de modo exibido no topo de qualquer página. Ele alterna entre
`vulnerable` e `fixed`, atualiza `APP_MODE` no `.env` e recarrega a página.

Também é possível editar manualmente o `.env`:

```env
APP_MODE=vulnerable   # demonstra as vulnerabilidades
APP_MODE=fixed        # demonstra as correções
```

A aplicação lê essa variável a cada requisição; portanto não é necessário
reiniciar o container após a alteração.

### Parar o laboratório

```bash
docker compose down
```

### Apagar dados do MySQL (reiniciar do zero)

```bash
docker compose down -v
docker compose up -d --build
```

### Codificação dos dados

O banco e a conexão usam `utf8mb4`. O `database/init.sql` já define essa
codificação antes de inserir dados. Para uma instalação antiga que apresente
texto como `JoÃ£o`, execute uma única vez o script
`database/fix-encoding.sql` no banco `vulnbox_lab`.

---

## Credenciais de Laboratório

> **Estas credenciais são fictícias e existem exclusivamente para o laboratório.**

| Usuário | Senha | Papel |
|---------|-------|-------|
| `admin` | `admin123` | Administrador |
| `manager` | `manager123` | Gerente |
| `user1` | `123456` | Usuário comum |
| `user2` | `password` | Usuário comum |
| `user3` | `!@3asd!@3` | Usuário comum |

---

## Endpoints

| Endpoint | Descrição | Vulnerabilidade |
|----------|-----------|-----------------|
| `/login.php` | Login | A07 |
| `/dashboard.php` | Painel principal | — |
| `/profile.php?id=N` | Perfil de usuário | A01 / IDOR |
| `/document.php?id=N` | Documento | A01 / IDOR |
| `/security.php` | Análise de sessão | A07 |
| `/admin/users.php` | Usuários (admin) | A01 / Escalada Vertical |
| `/admin/` | Entrada da área administrativa | A01 / Escalada Vertical |
| `/admin/logs.php` | Logs (admin) | A01 / Escalada Vertical |
| `/admin/settings.php` | Configurações (admin) | A01 / Escalada Vertical |

---

## Estrutura de Diretórios

```
vulnbox-lab/
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
├── gateway/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── waf/
│       ├── rules.lua
│       ├── banner.lua
│       └── gateway_api.lua
├── kali/
│   ├── Dockerfile
│   └── attacks/
│       ├── run_all.sh
│       ├── brute_force.sh
│       ├── wordlist.txt
│       ├── idor_profile.sh
│       ├── idor_document.sh
│       ├── admin_escalation.sh
│       ├── path_traversal.sh
│       ├── session_fixation.sh
│       └── scanner.sh
├── database/
│   ├── init.sql
│   └── fix-encoding.sql
├── docs/
│   ├── TESTES.md
│   ├── GATEWAY.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── toggle-mode.php
│   ├── .htaccess
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   ├── partials/
│   │   ├── topbar.php
│   │   └── sidebar.php
│   └── admin/
│       ├── index.php
│       ├── users.php
│       ├── logs.php
│       └── settings.php
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
└── assets/
    ├── css/style.css
    └── js/lab.js
```

---

## Documentação

- `docs/TESTES.md` — Roteiro de testes passo a passo
- `docs/MITIGACOES.md` — Explicação das correções
- `docs/IMPACTO.md` — Análise de impacto (CIA)

## Password mysql
- Host no Docker: mysql
- Banco: vulnbox_lab
- Usuário: labuser
- password: labpass123
