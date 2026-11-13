<?php
// ============================================================
// VULNBOX LAB — Segurança de Sessão
// A07: Session Management — vulnerável vs. corrigido
// ============================================================

require_once __DIR__ . '/../src/config.php';
require_once __DIR__ . '/../src/session.php';
require_once __DIR__ . '/../src/permissions.php';

requireLogin();
$user = currentUser();

// Captura informações da sessão atual
$sessionId     = session_id();
$cookieParams  = session_get_cookie_params();
$sessionData   = $_SESSION;
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Segurança de Sessão — <?= APP_NAME ?></title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body class="<?= modeClass() ?>">

<?php include __DIR__ . '/partials/topbar.php'; ?>
<?= modeBanner() ?>

<div class="container">
    <div class="layout">
        <?php include __DIR__ . '/partials/sidebar.php'; ?>

        <div class="content">
            <div class="card">
                <h2>🔒 Análise de Segurança da Sessão</h2>

                <?php if (isVulnerableMode()): ?>
                <div class="info-box vuln">
                    <strong>🔴 A07 — Sessão Insegura (MODO VULNERÁVEL)</strong>
                    Configurações problemáticas estão ativas. Veja os detalhes abaixo.
                </div>
                <?php else: ?>
                <div class="info-box fixed">
                    <strong>🟢 A07 — Sessão Segura (MODO CORRIGIDO)</strong>
                    Boas práticas de gerenciamento de sessão estão aplicadas.
                </div>
                <?php endif; ?>

                <!-- Configurações atuais -->
                <h2>⚙️ Configurações Atuais da Sessão</h2>
                <table>
                    <thead><tr><th>Parâmetro</th><th>Valor Atual</th><th>Status</th></tr></thead>
                    <tbody>
                        <?php
                        $httponly  = ini_get('session.cookie_httponly');
                        $secure    = ini_get('session.cookie_secure');
                        $samesite  = ini_get('session.cookie_samesite');
                        $lifetime  = ini_get('session.gc_maxlifetime');
                        $strict    = ini_get('session.use_strict_mode');

                        $checks = [
                            ['cookie_httponly', $httponly,  $httponly == 1,  'Impede acesso via JavaScript (XSS)'],
                            ['cookie_secure',   $secure,   $secure == 1,    'Restringe a HTTPS (em produção)'],
                            ['cookie_samesite', $samesite ?: '(vazio)', $samesite === 'Strict', 'Proteção contra CSRF'],
                            ['gc_maxlifetime',  $lifetime . 's', $lifetime <= 1800, 'Tempo de expiração da sessão'],
                            ['use_strict_mode', $strict,   $strict == 1,    'Rejeita IDs externos'],
                        ];

                        foreach ($checks as [$param, $value, $ok, $desc]):
                        ?>
                        <tr>
                            <td><code><?= $param ?></code><br><small style="color:#888;"><?= $desc ?></small></td>
                            <td><code><?= htmlspecialchars((string)$value) ?></code></td>
                            <td><?= $ok
                                ? '<span class="badge badge-fixed">✅ OK</span>'
                                : '<span class="badge badge-vuln">⚠️ Problema</span>' ?>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

            <div class="card">
                <h2>🪪 Dados da Sessão Atual</h2>
                <table>
                    <tr><th style="width:180px;">Campo</th><th>Valor</th></tr>
                    <tr><td>Session ID</td><td><code><?= htmlspecialchars($sessionId) ?></code></td></tr>
                    <tr><td>user_id</td><td><?= htmlspecialchars((string)($sessionData['user_id'] ?? '-')) ?></td></tr>
                    <tr><td>username</td><td><?= htmlspecialchars($sessionData['username'] ?? '-') ?></td></tr>
                    <tr><td>role</td><td><?= htmlspecialchars($sessionData['role'] ?? '-') ?></td></tr>
                    <tr><td>login_time</td>
                        <td><?= isset($sessionData['login_time'])
                            ? date('H:i:s d/m/Y', $sessionData['login_time'])
                            : '<span class="badge badge-vuln">⚠️ Não registrado (modo vulnerável)</span>' ?></td></tr>
                    <tr><td>last_activity</td>
                        <td><?= isset($sessionData['last_activity'])
                            ? date('H:i:s d/m/Y', $sessionData['last_activity'])
                            : '<span class="badge badge-vuln">⚠️ Não rastreado (modo vulnerável)</span>' ?></td></tr>
                </table>
            </div>

            <div class="card">
                <h2>📖 Comparativo: Vulnerável vs. Corrigido</h2>
                <table>
                    <thead><tr><th>Aspecto</th><th>🔴 Vulnerável</th><th>🟢 Corrigido</th></tr></thead>
                    <tbody>
                        <tr>
                            <td>Regeneração de ID</td>
                            <td>Não regenera após login</td>
                            <td><code>session_regenerate_id(true)</code></td>
                        </tr>
                        <tr>
                            <td>Cookie HttpOnly</td>
                            <td>Desativado (JS acessa)</td>
                            <td>Ativado</td>
                        </tr>
                        <tr>
                            <td>Cookie SameSite</td>
                            <td>Não configurado (CSRF)</td>
                            <td>Strict</td>
                        </tr>
                        <tr>
                            <td>Expiração de sessão</td>
                            <td>86400s (24h)</td>
                            <td><?= SESSION_LIFETIME ?>s (<?= SESSION_LIFETIME/60 ?> min)</td>
                        </tr>
                        <tr>
                            <td>Timeout por inatividade</td>
                            <td>Sem controle</td>
                            <td>Rastreado por <code>last_activity</code></td>
                        </tr>
                        <tr>
                            <td>Logout</td>
                            <td>Pode não destruir a sessão</td>
                            <td><code>session_destroy()</code> + limpeza do cookie</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="info-box">
                <strong>💡 Como testar Session Fixation no modo vulnerável:</strong>
                1. Abra o DevTools (F12) → aba Application → Cookies<br>
                2. Anote o valor do cookie <code>PHPSESSID</code> antes do login<br>
                3. Faça logout e login novamente<br>
                4. <strong>Modo Vulnerável:</strong> o ID da sessão permanece o mesmo antes e após o login (Session Fixation possível)<br>
                5. <strong>Modo Corrigido:</strong> o ID muda após o login (<code>session_regenerate_id</code> aplicado)
            </div>
        </div>
    </div>
</div>
</body>
</html>
