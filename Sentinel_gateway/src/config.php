<?php
// ============================================================
// VULNBOX LAB — Configuração Central
// Lê variáveis de ambiente injetadas pelo Docker Compose
// ============================================================

define('APP_NAME',    'Vulnbox Lab');
define('APP_VERSION', '1.0.0');

// Modo da aplicação: 'vulnerable' ou 'fixed'. O .env é consultado a cada
// requisição para que a troca pelo banner tenha efeito imediato no Docker.
function appModeFromEnvFile(): string {
    $envFile = dirname(__DIR__) . '/.env';

    if (is_readable($envFile)) {
        foreach (file($envFile, FILE_IGNORE_NEW_LINES) ?: [] as $line) {
            $trimmed = trim($line);
            if ($trimmed === '' || $trimmed[0] === '#') {
                continue;
            }
            if (preg_match('/^\s*APP_MODE\s*=\s*["\']?(vulnerable|fixed)["\']?\s*(?:#.*)?$/i', $line, $matches)) {
                return strtolower($matches[1]);
            }
        }
    }

    $mode = strtolower((string) getenv('APP_MODE'));
    return in_array($mode, ['vulnerable', 'fixed'], true) ? $mode : 'vulnerable';
}

define('APP_MODE', appModeFromEnvFile());

// Banco de dados
define('DB_HOST', getenv('DB_HOST') ?: 'mysql');
define('DB_PORT', getenv('DB_PORT') ?: '3306');
define('DB_NAME', getenv('DB_NAME') ?: 'vulnbox_lab');
define('DB_USER', getenv('DB_USER') ?: 'labuser');
define('DB_PASS', getenv('DB_PASS') ?: 'labpass123');

// Sessão
define('SESSION_LIFETIME',    (int)(getenv('SESSION_LIFETIME')    ?: 1800));

// Proteção contra força bruta
define('MAX_LOGIN_ATTEMPTS',  (int)(getenv('MAX_LOGIN_ATTEMPTS')  ?: 5));
define('LOCKOUT_MINUTES',     (int)(getenv('LOCKOUT_MINUTES')     ?: 15));

// Funções auxiliares de modo
function isVulnerableMode(): bool {
    return APP_MODE === 'vulnerable';
}

function isFixedMode(): bool {
    return APP_MODE === 'fixed';
}

// Retorna badge HTML identificando o modo atual
function modeBadge(): string {
    if (isVulnerableMode()) {
        return '<span class="badge badge-vuln">⚠️ MODO VULNERÁVEL</span>';
    }
    return '<span class="badge badge-fixed">✅ MODO CORRIGIDO</span>';
}

// Retorna classe CSS do modo
function modeClass(): string {
    return isVulnerableMode() ? 'mode-vulnerable' : 'mode-fixed';
}

/** Atualiza somente APP_MODE e preserva as demais variáveis do .env. */
function setAppMode(string $mode): bool {
    if (!in_array($mode, ['vulnerable', 'fixed'], true)) {
        return false;
    }

    $envFile = dirname(__DIR__) . '/.env';
    if (!is_readable($envFile) || !is_writable($envFile)) {
        return false;
    }

    $contents = file_get_contents($envFile);
    if ($contents === false) {
        return false;
    }

    $updated = preg_replace('/^\s*APP_MODE\s*=.*$/mi', 'APP_MODE=' . $mode, $contents, 1, $replacements);
    if ($updated === null) {
        return false;
    }
    if ($replacements === 0) {
        $updated = rtrim($contents) . PHP_EOL . 'APP_MODE=' . $mode . PHP_EOL;
    }

    // Escrita direta: .env é um bind mount no Docker e não pode ser
    // substituído por rename() a partir de dentro do container.
    return file_put_contents($envFile, $updated, LOCK_EX) !== false;
}

/** Renderiza o banner e a ação que alterna o modo do laboratório. */
function modeBanner(string $suffix = ''): string {
    if (session_status() !== PHP_SESSION_ACTIVE) {
        return '<div class="mode-banner">' . modeBadge() . $suffix . '</div>';
    }

    if (empty($_SESSION['mode_toggle_token'])) {
        $_SESSION['mode_toggle_token'] = bin2hex(random_bytes(32));
    }

    $nextMode = isVulnerableMode() ? 'corrigido' : 'vulnerável';
    return '<div class="mode-banner">'
        . '<form method="post" action="/toggle-mode.php" class="mode-toggle-form">'
        . '<input type="hidden" name="token" value="' . htmlspecialchars($_SESSION['mode_toggle_token'], ENT_QUOTES, 'UTF-8') . '">'
        . '<input type="hidden" name="return_to" value="' . htmlspecialchars($_SERVER['REQUEST_URI'] ?? '/', ENT_QUOTES, 'UTF-8') . '">'
        . '<button type="submit" class="mode-toggle" title="Alternar para o modo ' . $nextMode . '">'
        . modeBadge() . $suffix . ' <span class="mode-toggle-hint">Clique para alternar para ' . $nextMode . '</span>'
        . '</button></form></div>';
}
