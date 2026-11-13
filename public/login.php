<?php
// ============================================================
// VULNBOX LAB — Login
// A07: Identification and Authentication Failures
// ============================================================

require_once __DIR__ . '/../src/config.php';
require_once __DIR__ . '/../src/session.php';
require_once __DIR__ . '/../src/auth.php';

initSession();

// Já autenticado? Redireciona
if (!empty($_SESSION['logged_in'])) {
    header('Location: /dashboard.php');
    exit;
}

$error   = '';
$success = '';
$reason  = $_GET['reason'] ?? '';

// ---- Processa o formulário ----
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';
    $ip       = getClientIP();

    if ($username === '' || $password === '') {
        $error = 'Preencha usuário e senha.';
    } else {
        $user = authenticateUser($username, $password, $ip);

        if ($user) {
            loginSession($user);
            header('Location: /dashboard.php');
            exit;
        } else {
            if (isVulnerableMode()) {
                // VULNERÁVEL — mensagem específica pode revelar se o usuário existe
                $error = 'Credenciais inválidas.';
            } else {
                // CORRIGIDO — mensagem genérica
                $error = 'Usuário ou senha incorretos.';
            }
        }
    }
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login — <?= APP_NAME ?></title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body class="<?= modeClass() ?>">

<?= modeBanner(' &nbsp; ' . APP_NAME . ' — Sistema Administrativo de Laboratório') ?>

<div class="login-wrapper">
    <div class="login-box">
        <h1>🔐 <?= APP_NAME ?></h1>
        <p class="subtitle">Sistema Administrativo — Acesso Restrito</p>

        <?php if ($reason === 'timeout'): ?>
            <div class="alert alert-warn">Sua sessão expirou. Faça login novamente.</div>
        <?php endif; ?>

        <?php if ($error): ?>
            <div class="alert alert-error"><?= htmlspecialchars($error) ?></div>
        <?php endif; ?>

        <!-- ====================================================
             INFORMAÇÕES DO LAB (visíveis apenas para facilitar
             os exercícios acadêmicos)
             ==================================================== -->
        <div class="info-box warn">
            <strong>⚠️ Credenciais do Laboratório</strong>
            admin / admin123 &nbsp;|&nbsp; manager / manager123 &nbsp;|&nbsp; user1 / 123456
        </div>

        <div class="info-box" style="background:#f0f4ff; border-left:4px solid #2980b9; word-break:break-all;">
            <strong>🪪 Session ID (PHPSESSID):</strong>
            <code style="font-size:0.88rem; color:#1a365d; font-weight:600;"><?= htmlspecialchars(session_id()) ?></code>
            <small style="display:block; color:#666; margin-top:4px;">Observe se este ID se mantém ou se altera após o login.</small>
        </div>

        <form method="POST" action="/login.php">
            <div class="form-group">
                <label for="username">Usuário</label>
                <input type="text" id="username" name="username"
                       value="<?= htmlspecialchars($_POST['username'] ?? '') ?>"
                       autocomplete="username" required>
            </div>
            <div class="form-group">
                <label for="password">Senha</label>
                <input type="password" id="password" name="password"
                       autocomplete="current-password" required>
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%">Entrar</button>
        </form>

        <hr style="margin:20px 0; border-color:#eee;">

        <?php if (isVulnerableMode()): ?>
        <div class="info-box vuln">
            <strong>🔴 MODO VULNERÁVEL — Falhas A07 ativas:</strong>
            • Senhas fracas armazenadas em texto puro<br>
            • Sem bloqueio por força bruta<br>
            • Sessão sem regeneração de ID após login<br>
            • Cookies sem atributos HttpOnly/Secure/SameSite
        </div>
        <?php else: ?>
        <div class="info-box fixed">
            <strong>🟢 MODO CORRIGIDO — Proteções A07 ativas:</strong>
            • Senhas com hash bcrypt (password_hash)<br>
            • Bloqueio após <?= MAX_LOGIN_ATTEMPTS ?> tentativas (<?= LOCKOUT_MINUTES ?> min)<br>
            • Regeneração de ID de sessão após login<br>
            • Timeout de sessão em <?= SESSION_LIFETIME/60 ?> minutos
        </div>
        <?php endif; ?>
    </div>
</div>

</body>
</html>
