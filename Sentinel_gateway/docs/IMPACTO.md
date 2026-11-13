# 📊 Vulnbox Lab — Análise de Impacto

> Análise baseada nos princípios da tríade CIA:
> **Confidencialidade · Integridade · Disponibilidade**

---

## A01 — Broken Access Control

### Confidencialidade

**Impacto: ALTO / CRÍTICO**

- Acesso indevido a perfis de outros usuários (nome, e-mail, papel, status)
- Leitura de documentos classificados (orçamentos, configurações, relatórios gerenciais)
- Exposição de dados administrativos por usuários sem privilégio
- Vazamento de estrutura interna do sistema (IDs previsíveis, papéis de usuários)
- **Path Traversal:** Leitura arbitrária de arquivos do sistema e configurações sensíveis (ex: `.env`, `/etc/passwd`) via `sensitive_access.php`
- **Directory Listing (`Index of /caminho`):** Navegação e enumeração de arquivos do servidor web quando a listagem de diretório está ativa (ex: diretórios `/src/` e `/admin/`)

**Cenário real:** Um usuário comum acessa `/document.php?id=1` e lê o orçamento anual da empresa, ou executa `/sensitive_access.php?file=../../.env` obtendo credenciais do banco de dados, ou navega por `/src/` através do `Index of /src/` descobrindo scripts legados e backups.

---

### Integridade

**Impacto: MÉDIO–ALTO**

- Além da alteração de status implementada no lab, falhas equivalentes em sistemas com edição podem permitir modificar outros dados de terceiros
- No modo vulnerável, usuário comum que alcança `/admin/users.php` pode ativar ou desativar contas de terceiros
- Escalada vertical permite que usuário comum acesse painéis administrativos e potencialmente altere configurações
- Contaminação de registros de auditoria (usuário sem permissão executando ações registradas como seu próprio ID)

**Cenário real:** Atacante acessa `/admin/users.php` e desativa a conta de um funcionário ou de outro administrador, interrompendo seu acesso.

---

### Disponibilidade

**Impacto: MÉDIO**

- No modo vulnerável, qualquer autenticado que alcance a tela administrativa pode desativar contas legítimas
- Acesso a logs permite identificar padrões de uso e preparar ataques mais sofisticados
- Escalada vertical pode expor funcionalidades de exclusão de dados

---

## A07 — Identification and Authentication Failures

### Confidencialidade

**Impacto: CRÍTICO**

- Senhas em texto puro: em caso de dump do banco, todas as senhas são expostas imediatamente
- Senhas fracas / Política de Senha Fraca: aceitação de senhas triviais (ex: `123`, `123456`) facilmente descobertas por ataques de dicionário e força bruta em segundos
- Reutilização de senhas: usuários que usam a mesma senha em outros serviços são comprometidos em cascata

**Cenário real:** Dump do banco `vulnbox_lab` expõe 5 senhas em texto puro. Atacante testa as mesmas senhas em e-mail, bancos e redes sociais dos usuários, ou usa wordlists comuns para adivinhar senhas sem complexidade mínima.

---

### Integridade

**Impacto: ALTO**

- Comprometimento de conta admin permite alteração de qualquer dado no sistema
- Ausência de Session Fixation permite que atacante pré-defina um Session ID e assuma a sessão do usuário após o login
- Cookie sem `HttpOnly` permite roubo de sessão via XSS, dando controle total da sessão ao atacante

**Cenário real:** Atacante injeta script em campo não sanitizado, captura o `PHPSESSID` da vítima (sem `HttpOnly`) e assume a sessão autenticada.

---

### Disponibilidade

**Impacto: MÉDIO**

- Sem proteção contra força bruta: tentativas ilimitadas facilitam sobrecarga do endpoint de autenticação e descoberta de credenciais
- Sessões sem timeout: sessões de usuários demitidos ou dispositivos perdidos permanecem válidas indefinidamente

**Cenário real (modo corrigido — efeito colateral):** Um atacante tenta `admin / errado` 5 vezes e bloqueia a conta do administrador real por 15 minutos.

---

## Tabela de Impacto Consolidada

| Vulnerabilidade | Confidencialidade | Integridade | Disponibilidade | Risco Global |
|-----------------|:-----------------:|:-----------:|:---------------:|:------------:|
| IDOR Perfil | 🔴 Alto | 🟡 Médio | 🟢 Baixo | **Alto** |
| IDOR Documento | 🔴 Alto | 🟡 Médio | 🟢 Baixo | **Alto** |
| Escalada Vertical | 🔴 Alto | 🔴 Alto | 🟡 Médio | **Crítico** |
| Path Traversal & Directory Listing | 🔴 Crítico | 🟢 Baixo | 🟢 Baixo | **Crítico** |
| Senha em texto puro | 🔴 Crítico | 🔴 Alto | 🟢 Baixo | **Crítico** |
| Política de Senha Fraca | 🔴 Alto | 🟡 Médio | 🟢 Baixo | **Alto** |
| Sem proteção força bruta | 🔴 Alto | 🟡 Médio | 🟡 Médio | **Alto** |
| Session Fixation | 🔴 Alto | 🔴 Alto | 🟡 Médio | **Alto** |
| Cookie inseguro (sem HttpOnly) | 🔴 Alto | 🔴 Alto | 🟢 Baixo | **Alto** |
| Alteração indevida de status de conta | 🟡 Médio | 🔴 Alto | 🟡 Médio | **Alto** |

---

## Referências

- [OWASP Top 10 — A01:2021](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
- [OWASP Top 10 — A07:2021](https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/)
- [OWASP IDOR Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [OWASP Session Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html)
