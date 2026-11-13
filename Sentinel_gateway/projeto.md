## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
## PROMPT — DESENVOLVIMENTO DE LABORATÓRIO WEB VULNERÁVEL OWASP A01 E A07

Atue como um desenvolvedor web sênior, especialista em segurança de aplicações, OWASP Top 10, PHP, MySQL, Docker e ambientes de laboratório para testes de segurança.

Preciso desenvolver uma **aplicação web propositalmente vulnerável**, destinada exclusivamente a um **laboratório acadêmico de cibersegurança em ambiente controlado**, para demonstrar vulnerabilidades relacionadas ao:

* **OWASP Top 10 — A01: Broken Access Control**
* **OWASP Top 10 — A07: Identification and Authentication Failures**

A aplicação deverá ser executada integralmente em **Docker**, utilizando:

* PHP;
* MySQL;
* Apache ou Nginx;
* Docker Compose;
* HTML5;
* CSS;
* JavaScript quando necessário.

O projeto deve ser simples de instalar, executar e estudar, mas suficientemente completo para permitir a demonstração prática das vulnerabilidades.

---

# 1. OBJETIVO GERAL

Desenvolver uma aplicação web vulnerável que simule um sistema administrativo corporativo e permita demonstrar, em ambiente controlado, vulnerabilidades de controle de acesso e falhas de identificação/autenticação.

A aplicação deverá possuir usuários com diferentes níveis de privilégio, dados administrativos e endpoints que possam ser utilizados para demonstrar as vulnerabilidades.

O sistema deverá possuir dois estados:

### Modo 1 — VULNERÁVEL

Implementar propositalmente as vulnerabilidades relacionadas ao A01 e A07.

### Modo 2 — CORRIGIDO

Implementar as respectivas medidas de mitigação, permitindo comparar o comportamento vulnerável com o comportamento seguro.

A aplicação deverá deixar claramente identificável quando determinado recurso está vulnerável e quando está protegido.

---

# 2. AMBIENTE DO PROJETO

Utilize a seguinte arquitetura:

```text
Docker Compose
│
├── web
│   ├── PHP
│   └── Apache
│
└── mysql
    └── MySQL
```

Criar:

```text
docker-compose.yml
```

e um Dockerfile para o container PHP.

O banco de dados deverá utilizar MySQL.

As credenciais e configurações deverão ser definidas por variáveis de ambiente no Docker Compose, evitando colocar credenciais diretamente no código PHP.

---

# 3. ESTRUTURA DA APLICAÇÃO

Criar uma aplicação chamada, por exemplo:

```text
Vulnbox Lab
```

A aplicação deverá simular um sistema corporativo chamado:

```text
Sistema Administrativo
```

Criar pelo menos os seguintes perfis:

```text
admin
manager
user
```

Exemplo:

```text
admin    → acesso administrativo completo
manager  → acesso intermediário
user     → acesso limitado
```

Criar também usuários de teste para cada perfil.

As senhas utilizadas no laboratório podem ser propositalmente fracas na versão vulnerável, mas devem ser claramente identificadas como credenciais de laboratório.

---

# 4. FUNCIONALIDADES DA APLICAÇÃO

Criar pelo menos os seguintes módulos:

## 4.1 Login

Página:

```text
/login.php
```

Campos:

```text
Usuário
Senha
```

Após autenticação, redirecionar o usuário para:

```text
/dashboard.php
```

---

## 4.2 Dashboard

Exibir:

* nome do usuário;
* perfil;
* ID do usuário;
* opções disponíveis de acordo com o perfil;
* informações gerais do sistema.

---

## 4.3 Perfil do usuário

Criar:

```text
/profile.php?id=ID
```

Esse endpoint deverá ser utilizado para demonstrar **IDOR / Insecure Direct Object Reference**.

Na versão vulnerável, demonstrar o problema de forma didática, permitindo que um usuário acesse dados pertencentes a outro usuário apenas alterando o identificador.

Exemplo conceitual:

```text
/profile.php?id=10
/profile.php?id=11
/profile.php?id=12
```

Explicar no código onde ocorre a falha.

Na versão corrigida:

* validar autorização no servidor;
* garantir que o usuário somente consiga acessar seu próprio registro, salvo quando possuir permissão adequada;
* nunca confiar apenas no ID fornecido pelo cliente.

---

# 5. OWASP A01 — BROKEN ACCESS CONTROL

Implementar exemplos didáticos das seguintes vulnerabilidades.

## 5.1 Escalada horizontal de privilégio

Demonstrar situação em que:

```text
Usuário A → consegue acessar dados do Usuário B
```

mesmo sem possuir autorização.

Utilizar o endpoint:

```text
/profile.php?id=...
```

ou outro endpoint apropriado.

Explicar:

* qual é o recurso protegido;
* qual é a falha;
* por que ocorre;
* como seria explorada no laboratório;
* impacto;
* como corrigir.

---

# 5.2 Escalada vertical de privilégio

Criar uma área administrativa:

```text
/admin/
```

com funcionalidades como:

```text
/admin/users.php
/admin/settings.php
/admin/logs.php
```

Na versão vulnerável, permitir que um usuário com baixo privilégio consiga acessar alguma dessas funcionalidades por meio de acesso direto ao endpoint.

Exemplo conceitual:

```text
/user → /admin/users.php
```

A aplicação deverá demonstrar que esconder o link do menu não constitui controle de acesso.

A autorização deverá ser realizada no servidor.

---

# 5.3 IDOR

Criar um recurso que utilize identificadores previsíveis:

```text
/document.php?id=1
/document.php?id=2
/document.php?id=3
```

Na versão vulnerável, permitir acesso indevido a recursos de outros usuários.

Na versão corrigida:

* verificar autenticação;
* verificar autorização;
* verificar propriedade do recurso;
* aplicar RBAC quando necessário.

---

# 6. OWASP A07 — IDENTIFICATION AND AUTHENTICATION FAILURES

Implementar exemplos didáticos das seguintes falhas.

## 6.1 Senhas fracas

Criar usuários de laboratório com senhas propositalmente fracas.

Exemplo:

```text
admin / admin123
user / 123456
```

Deixar claro na documentação que essas credenciais existem somente para o laboratório.

Na versão corrigida:

* armazenar senhas utilizando `password_hash()`;
* validar utilizando `password_verify()`;
* estabelecer política mínima de senha;
* não armazenar senhas em texto puro.

---

# 6.2 Proteção contra força bruta

Na versão vulnerável:

Permitir várias tentativas consecutivas de login sem bloqueio ou limitação adequada.

Registrar tentativas de autenticação no banco.

Criar uma tabela:

```text
login_attempts
```

com informações como:

```text
id
username
ip_address
attempt_time
success
```

Na versão corrigida:

Implementar política de bloqueio de conta.

Exemplo:

```text
5 tentativas inválidas
        ↓
bloqueio temporário
        ↓
15 minutos
        ↓
nova tentativa permitida
```

Os parâmetros devem ser configuráveis por variáveis de ambiente ou arquivo de configuração.

Também registrar o evento de bloqueio.

---

# 6.3 Bypass de sessão

Criar uma demonstração controlada de falha relacionada ao gerenciamento de sessão.

Na versão vulnerável, apresentar uma implementação insegura de sessão que permita demonstrar problemas como:

* ausência de regeneração do ID de sessão após login;
* ausência de controles adequados de sessão;
* cookies sem atributos de segurança apropriados;
* ausência de expiração adequada.

IMPORTANTE:

A demonstração deve permanecer restrita à própria aplicação do laboratório.

Na versão corrigida implementar:

```php
session_regenerate_id(true);
```

após autenticação.

Configurar adequadamente:

```text
HttpOnly
Secure
SameSite
```

quando aplicável.

Implementar timeout de sessão.

Destruir corretamente a sessão no logout.

---

# 7. BANCO DE DADOS MYSQL

Criar um banco chamado:

```text
vulnbox_lab
```

Criar tabelas pelo menos para:

```text
users
documents
login_attempts
audit_logs
```

Sugestão:

### users

```text
id
username
password
role
name
email
status
failed_attempts
locked_until
created_at
```

### documents

```text
id
user_id
title
content
created_at
```

### login_attempts

```text
id
username
ip_address
attempt_time
success
```

### audit_logs

```text
id
user_id
action
ip_address
created_at
```

Criar arquivo:

```text
database/init.sql
```

com:

* criação das tabelas;
* índices;
* usuários de laboratório;
* dados de exemplo;
* documentos de exemplo.

---

# 8. RBAC — MITIGAÇÃO DO A01

Implementar Controle de Acesso Baseado em Funções.

Criar uma estrutura centralizada, por exemplo:

```text
auth.php
permissions.php
```

Definir permissões como:

```text
USER
    view_own_profile
    view_own_documents

MANAGER
    view_users
    view_documents
    view_reports

ADMIN
    manage_users
    manage_documents
    view_logs
    manage_settings
```

Criar funções como:

```php
requireLogin();

requireRole('admin');

requirePermission('view_users');
```

O controle de autorização deverá ocorrer no servidor.

Não depender apenas de:

* menus;
* botões ocultos;
* JavaScript;
* URLs não divulgadas.

---

# 9. COMPARAÇÃO VULNERÁVEL × CORRIGIDO

Criar uma página:

```text
/security.php
```

que apresente:

| Vulnerabilidade     | Estado               | Mitigação                |
| ------------------- | -------------------- | ------------------------ |
| IDOR                | Vulnerável/Corrigido | Controle de autorização  |
| Escalada horizontal | Vulnerável/Corrigido | Validação de propriedade |
| Escalada vertical   | Vulnerável/Corrigido | RBAC                     |
| Senha fraca         | Vulnerável/Corrigido | Política de senha        |
| Força bruta         | Vulnerável/Corrigido | Bloqueio de conta        |
| Sessão insegura     | Vulnerável/Corrigido | Gestão segura de sessão  |

Criar um mecanismo simples para alternar entre:

```text
VULNERABLE=true
```

e

```text
VULNERABLE=false
```

por meio de variável de ambiente.

Não duplicar desnecessariamente todo o projeto.

---

# 10. ENDPOINTS

Criar uma documentação dos endpoints existentes.

Exemplo:

```text
GET  /login.php
POST /login.php

GET  /dashboard.php

GET  /profile.php?id=

GET  /document.php?id=

GET  /admin/users.php

GET  /admin/logs.php

POST /logout.php
```

Para cada endpoint informar:

* método HTTP;
* finalidade;
* autenticação necessária;
* perfil necessário;
* vulnerabilidade relacionada;
* comportamento vulnerável;
* comportamento corrigido.

---

# 11. LOGS E AUDITORIA

Implementar registro de eventos importantes:

```text
LOGIN_SUCCESS
LOGIN_FAILURE
ACCOUNT_LOCKED
LOGOUT
UNAUTHORIZED_ACCESS
PROFILE_ACCESS
DOCUMENT_ACCESS
ADMIN_ACCESS
```

Registrar:

```text
usuário
IP
data/hora
ação
```

Criar uma página administrativa para visualizar os logs.

Somente usuários com permissão administrativa poderão visualizar os logs na versão corrigida.

---

# 12. INTERFACE

Criar uma interface simples, limpa e responsiva.

Utilizar:

```text
HTML5
CSS3
Bootstrap
```

se considerar adequado.

A interface deve possuir:

* tela de login;
* dashboard;
* menu lateral;
* perfil;
* documentos;
* área administrativa;
* logs;
* página de segurança/laboratório.

Mostrar visualmente o nível do usuário:

```text
ADMIN
MANAGER
USER
```

---

# 13. DOCUMENTAÇÃO DO LABORATÓRIO

Criar um arquivo:

```text
README.md
```

explicando detalhadamente:

1. Objetivo do laboratório;
2. Arquitetura;
3. Pré-requisitos;
4. Instalação do Docker;
5. Configuração;
6. Como executar;
7. Como parar;
8. Como resetar o banco;
9. Credenciais de laboratório;
10. Endpoints;
11. A01;
12. A07;
13. Cenários de exploração;
14. Impactos;
15. Mitigações;
16. Como alternar entre modo vulnerável e corrigido.

---

# 14. GUIA DE TESTES

Criar:

```text
docs/TESTES.md
```

com um roteiro passo a passo para o aluno executar os testes.

Organizar assim:

## TESTE 01 — Escalada horizontal

Pré-condição:

```text
login como user
```

Objetivo:

Demonstrar acesso indevido ao recurso de outro usuário.

Explicar:

```text
1. Fazer login.
2. Acessar o próprio perfil.
3. Observar o ID.
4. Alterar o parâmetro ID.
5. Observar o comportamento.
6. Explicar o impacto.
7. Ativar a correção.
8. Repetir o teste.
9. Comparar os resultados.
```

---

## TESTE 02 — Escalada vertical

Demonstrar tentativa de acesso de:

```text
USER → ADMIN
```

Comparar:

```text
modo vulnerável
```

com:

```text
modo corrigido
```

---

## TESTE 03 — IDOR

Demonstrar alteração do identificador do recurso e verificar se outro recurso pode ser acessado.

---

## TESTE 04 — Senha fraca

Demonstrar que credenciais fracas podem comprometer a conta.

---

## TESTE 05 — Força bruta

Utilizar exclusivamente os endpoints da própria aplicação.

Demonstrar:

```text
tentativa 1
tentativa 2
tentativa 3
...
tentativa 5
→ bloqueio
```

Na versão corrigida.

Não implementar ou orientar ataques contra sistemas externos.

---

## TESTE 06 — Gerenciamento de sessão

Demonstrar, exclusivamente dentro do laboratório, o comportamento da sessão vulnerável e posteriormente a sessão corrigida.

---

# 15. ANÁLISE DE IMPACTO

Criar:

```text
docs/IMPACTO.md
```

Explicar os impactos considerando:

### Confidencialidade

Exemplo:

```text
Acesso indevido a documentos e informações administrativas.
```

### Integridade

Exemplo:

```text
Possibilidade de alteração de informações por usuário sem autorização.
```

### Disponibilidade

Exemplo:

```text
Bloqueio de contas por excesso de tentativas.
```

Relacionar os impactos aos princípios:

```text
Confidencialidade
Integridade
Disponibilidade
```

---

# 16. SEGURANÇA DO PRÓPRIO LABORATÓRIO

A aplicação deve ser projetada para funcionar em ambiente isolado.

Incluir no README uma advertência:

```text
ESTE SISTEMA É INTENCIONALMENTE VULNERÁVEL.

Utilizar exclusivamente em ambiente controlado de laboratório.
Não expor a Internet ou a redes de produção.
```

Não utilizar dados reais.

Não implementar funcionalidades que permitam atacar sistemas externos.

---

# 17. ESTRUTURA DE DIRETÓRIOS

Entregar uma estrutura semelhante a:

```text
vulnbox-lab/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── README.md
│
├── database/
│   └── init.sql
│
├── docs/
│   ├── TESTES.md
│   ├── IMPACTO.md
│   └── MITIGACOES.md
│
├── public/
│   ├── index.php
│   ├── login.php
│   ├── logout.php
│   ├── dashboard.php
│   ├── profile.php
│   ├── document.php
│   ├── security.php
│   │
│   └── admin/
│       ├── users.php
│       ├── logs.php
│       └── settings.php
│
├── src/
│   ├── config.php
│   ├── database.php
│   ├── auth.php
│   ├── permissions.php
│   ├── session.php
│   └── logger.php
│
└── assets/
    ├── css/
    └── js/
```

Você pode modificar essa estrutura caso exista uma arquitetura PHP melhor, mas explique a alteração.

---

# 18. REQUISITOS DE CÓDIGO

O código deve:

* utilizar PHP moderno;
* utilizar PDO para acesso ao MySQL;
* utilizar prepared statements;
* separar configuração, autenticação, autorização e acesso ao banco;
* utilizar funções reutilizáveis;
* possuir comentários didáticos;
* evitar código desnecessariamente complexo;
* ser adequado para estudantes de segurança da informação.

IMPORTANTE:

Como o objetivo é estudar vulnerabilidades, mostre claramente no código onde está a implementação vulnerável e onde está a implementação corrigida.

Utilize comentários como:

```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário.
```

e:

```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar o recurso.
```

---

# 19. DOCKER

O projeto deve funcionar com:

```bash
docker compose up -d --build
```

e ser acessível, por exemplo, em:

```text
http://localhost:8080
```

Criar também instruções para:

```bash
docker compose down
```

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.

e para apagar os dados persistentes do MySQL quando necessário.

Utilizar volume Docker para persistência do banco.

---

# 20. CRITÉRIOS DE ACEITAÇÃO

Considere o projeto concluído somente quando:

* [ ] Aplicação PHP funcionando;
* [ ] MySQL funcionando;
* [ ] Docker Compose funcionando;
* [ ] Login funcionando;
* [ ] Perfis USER/MANAGER/ADMIN funcionando;
* [ ] A01 implementado;
* [ ] IDOR implementado;
* [ ] Escalada horizontal demonstrável;
* [ ] Escalada vertical demonstrável;
* [ ] A07 implementado;
* [ ] Senhas fracas demonstráveis;
* [ ] Falha de proteção contra força bruta demonstrável;
* [ ] Problema de gerenciamento de sessão demonstrável;
* [ ] RBAC implementado;
* [ ] Bloqueio de conta implementado;
* [ ] Logs implementados;
* [ ] Modo vulnerável implementado;
* [ ] Modo corrigido implementado;
* [ ] Documentação criada;
* [ ] Guia de testes criado;
* [ ] Guia de mitigação criado.

---

# 21. FORMA DE ENTREGA

Não forneça apenas exemplos ou trechos de código.

Quero o projeto completo.

Apresente a resposta nesta ordem:

### ETAPA 1

Explique a arquitetura.

### ETAPA 2

Mostre a estrutura completa de diretórios.

### ETAPA 3

Forneça o conteúdo completo de cada arquivo necessário.

Para cada arquivo informe:

```text
ARQUIVO:
caminho/nome.ext
```

seguido pelo código completo.

### ETAPA 4

Explique como construir e executar:

```bash
docker compose up -d --build
```

### ETAPA 5

Explique como acessar a aplicação.

### ETAPA 6

Apresente as credenciais de laboratório.

### ETAPA 7

Apresente os endpoints.

### ETAPA 8

Explique cada vulnerabilidade A01.

### ETAPA 9

Explique cada vulnerabilidade A07.

### ETAPA 10

Apresente o roteiro de testes.

### ETAPA 11

Explique as mitigações.

### ETAPA 12

Explique como demonstrar a diferença entre:

```text
VULNERÁVEL
```

e:

```text
CORRIGIDO
```

---

# 22. RESTRIÇÃO IMPORTANTE

Este projeto será utilizado exclusivamente em laboratório acadêmico controlado.

As funcionalidades vulneráveis devem estar limitadas à própria aplicação criada pelo projeto.

Não criar mecanismos destinados a atacar sistemas externos, coletar credenciais reais, realizar persistência, evasão ou exploração fora do ambiente de laboratório.

Priorize a clareza didática e a capacidade de reproduzir os cenários de A01 e A07.

Antes de gerar o código, faça uma breve revisão da arquitetura proposta e identifique possíveis problemas de implementação.

Depois disso, gere o projeto completo.
