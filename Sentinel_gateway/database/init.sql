-- ============================================================
-- VULNBOX LAB — Inicialização do Banco de Dados
-- Banco: vulnbox_lab
-- ATENÇÃO: dados fictícios exclusivos para laboratório
-- ============================================================

-- O cliente usado pelo entrypoint do MySQL pode iniciar em latin1. Definir a
-- conexão antes de inserir os textos impede caracteres como "João" de serem
-- gravados como "JoÃ£o".
SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS vulnbox_lab CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON vulnbox_lab.* TO 'labuser'@'%';
FLUSH PRIVILEGES;
USE vulnbox_lab;

-- ============================================================
-- TABELA: users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username       VARCHAR(64)  NOT NULL UNIQUE,
    password       VARCHAR(255) NOT NULL,          -- hash bcrypt ou texto puro (modo vulnerável)
    password_plain VARCHAR(64)  DEFAULT NULL,       -- apenas para fins didáticos no lab
    role           ENUM('admin','manager','user') NOT NULL DEFAULT 'user',
    name           VARCHAR(128) NOT NULL,
    email          VARCHAR(128) NOT NULL,
    status         ENUM('active','locked','inactive') NOT NULL DEFAULT 'active',
    failed_attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
    locked_until   DATETIME DEFAULT NULL,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_role (role),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABELA: documents
-- ============================================================
CREATE TABLE IF NOT EXISTS documents (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id    INT UNSIGNED NOT NULL,
    title      VARCHAR(255) NOT NULL,
    content    TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABELA: login_attempts
-- ============================================================
CREATE TABLE IF NOT EXISTS login_attempts (
    id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username     VARCHAR(64)  NOT NULL,
    ip_address   VARCHAR(45)  NOT NULL,
    attempt_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    success      TINYINT(1)   NOT NULL DEFAULT 0,
    INDEX idx_username_time (username, attempt_time),
    INDEX idx_ip (ip_address)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABELA: audit_logs
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id    INT UNSIGNED DEFAULT NULL,
    action     VARCHAR(255) NOT NULL,
    detail     TEXT DEFAULT NULL,
    ip_address VARCHAR(45)  NOT NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- DADOS: usuários de laboratório
-- SENHAS FRACAS INTENCIONAIS — apenas para demonstração A07
-- Hashes bcrypt das senhas fracas (também armazenadas em texto
-- puro no campo password_plain apenas para fins didáticos)
-- ============================================================

-- admin / admin123
-- manager / manager123
-- user1 / 123456
-- user2 / password
-- user3 / !@3asd!@3

INSERT INTO users (username, password, password_plain, role, name, email, status) VALUES
(
    'admin',
    '$2y$10$e085qiz/xS9Oz6Y4GCf.bu45Cc9QNOXJ2DXGGllhqQ/bjy7YwR75e', -- senha: admin123 (hash bcrypt — mas fraca!)
    'admin123',
    'admin',
    'Administrador do Sistema',
    'admin@vulnboxlab.local',
    'active'
),
(
    'manager',
    '$2y$10$/vTMkONI8iEJFI2BLaHIdOT5RulH7ATp7D0vp3KPKMZVU4xwHgiCK', -- senha: manager123
    'manager123',
    'manager',
    'Gerente Operacional',
    'manager@vulnboxlab.local',
    'active'
),
(
    'user1',
    '$2y$10$0rlc4NnZJTzjTHn2GWcbVO.3bioJi16vbW/ai/KDBQGSDRqtjnGnW', -- senha: 123456
    '123456',
    'user',
    'João Silva',
    'joao.silva@vulnboxlab.local',
    'active'
),
(
    'user2',
    '$2y$10$f269.1F/ILbMMjhJIOVbDuzpx0iOoF2kZog0PnPrRlb.v5E/fUZhu', -- senha: password
    'password',
    'user',
    'Maria Souza',
    'maria.souza@vulnboxlab.local',
    'active'
),
(
    'user3',
    '$2y$10$2sLOy6mtitTatmdR57DYpOLw6dEkeYqGv7Ir5M44m/svAV4JBX6KS', -- senha: !@3asd!@3
    '!@3asd!@3',
    'user',
    'Carlos Pereira',
    'carlos.pereira@vulnboxlab.local',
    'active'
);

-- Atualiza hashes com senhas corretas (via procedure para garantir bcrypt real)
-- Nota: os hashes acima são placeholders; o script PHP de inicialização
-- irá regenerar via password_hash() se necessário.
-- Para fins de laboratório, as senhas abaixo são aceitas diretamente no modo vulnerável.

-- ============================================================
-- DADOS: documentos de laboratório
-- ============================================================
INSERT INTO documents (user_id, title, content) VALUES
(1, 'Relatório Confidencial — Orçamento 2024',
   'CONFIDENCIAL — Uso restrito ao administrador.\nOrçamento aprovado: R$ 2.500.000,00\nProjeto Alpha: R$ 800.000,00\nProjeto Beta: R$ 700.000,00\nReserva operacional: R$ 1.000.000,00'),

(1, 'Configurações de Segurança do Sistema',
   'RESTRITO — Somente administradores.\nServidor principal: 192.168.1.10\nServidor backup: 192.168.1.11\nVPN gateway: 10.0.0.1\nChave de API (exemplo): sk-lab-demo-0001'),

(2, 'Relatório Gerencial — Q3 2024',
   'Relatório de desempenho do terceiro trimestre.\nMetas atingidas: 87%\nEquipe: 12 colaboradores\nProjetos ativos: 4\nObservações: Expansão prevista para Q4.'),

(2, 'Plano de Continuidade de Negócios',
   'GERENCIAL — Acesso intermediário.\nRPO: 4 horas\nRTO: 8 horas\nContatos de emergência: TI (ramal 2001), Segurança (ramal 2002)\nProcedimentos de backup: diário às 23h.'),

(3, 'Minhas Anotações de Trabalho',
   'Documento pessoal do usuário João Silva.\nProjeto em andamento: migração do sistema legado.\nPrazo: 30/11/2024\nResponsável: eu mesmo.'),

(4, 'Relatório Pessoal — Maria Souza',
   'Documento pessoal da usuária Maria Souza.\nAtividades da semana: revisão de processos.\nPendências: aprovação do gestor para novo acesso.\nObservação: solicitar treinamento de segurança.'),

(5, 'Notas do Usuário 3',
   'Documento pessoal do usuário Carlos Pereira.\nIdeia: automatizar o relatório semanal.\nFerramentas: Python + Pandas.\nStatus: em estudo.');
