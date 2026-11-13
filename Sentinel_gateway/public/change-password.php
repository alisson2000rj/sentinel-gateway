<?php
// ============================================================
// VULNBOX LAB — Trocar Senha
// A07: Identification and Authentication Failures
// ============================================================

require_once __DIR__ . '/../src/config.php';
require_once __DIR__ . '/../src/session.php';
require_once __DIR__ . '/../src/permissions.php';
require_once __DIR__ . '/../src/database.php';
require_once __DIR__ . '/../src/logger.php';
require_once __DIR__ . '/../src/auth.php';

requireLogin();
$user = currentUser();

$pwMsg     = '';
$pwMsgType = 'error';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $db2         = getDB();
    $newPass     = $_POST['new_password']     ?? '';
    $confirmPass = $_POST['confirm_password'] ?? '';
    $currentPass = $_POST['current_password'] ?? '';

    if ($newPass === '' || $confirmPass === '') {
        $pwMsg = 'Preencha todos os campos obrigatórios.';
    } elseif ($newPass !== $confirmPass) {
        $pwMsg = 'As senhas nao coincidem.';
    } elseif (strlen($newPass) < 6) {
        $pwMsg = 'A nova senha deve ter pelo menos 6 caracteres.';
    } elseif (isVulnerableMode()) {
        $stmt = $db2->prepare('UPDATE users SET password_plain=?, password=? WHERE id=?');
        $stmt->execute([$newPass, password_hash($newPass, PASSWORD_BCRYPT), $user['id']]);
        logAudit($user['id'], 'PASSWORD_CHANGE_VULN', 'Senha alterada sem verificacao da senha atual (VULNERAVEL)', getClientIP());
        $pwMsg     = 'Senha alterada com sucesso (MODO VULNERAVEL - senha atual nao foi verificada!).';
        $pwMsgType = 'warning';
    } else {
        $stmt = $db2->prepare('SELECT password FROM users WHERE id = ?');
        $stmt->execute([$user['id']]);
        $row = $stmt->fetch();
        if (!$row || !password_verify($currentPass, $row['password'])) {
            $pwMsg = 'Senha atual incorreta.';
            logAudit($user['id'], 'PASSWORD_CHANGE_FAILED', 'Tentativa de troca de senha com senha atual incorreta', getClientIP());
        } else {
            $hash = password_hash($newPass, PASSWORD_BCRYPT);
            $upd  = $db2->prepare('UPDATE users SET password=?, password_plain=? WHERE id=?');
            $upd->execute([$hash, $newPass, $user['id']]);
            logAudit($user['id'], 'PASSWORD_CHANGE', 'Senha alterada com sucesso (CORRIGIDO)', getClientIP());
            $pwMsg     = 'Senha alterada com sucesso!';
            $pwMsgType = 'success';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trocar Senha</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body class="<?= modeClass() ?>">

<?php include __DIR__ . '/partials/topbar.php'; ?>
<?= modeBanner() ?>

<div class="container">
    <div class="layout">
        <?php include __DIR__ . '/partials/sidebar.php'; ?>

        <div class="content">

            <?php if (isVulnerableMode()): ?>
            <div class="info-box vuln">
                <strong>A07 - Troca de Senha Vulneravel (MODO VULNERAVEL)</strong>
                <b>Falha:</b> o formulario <strong>nao exige a senha atual</strong>.<br>
                <b>Impacto:</b> qualquer pessoa com acesso a sessao pode trocar a senha sem conhecer a anterior.<br>
                <b>Correcao:</b> ativar APP_MODE=fixed.
            </div>
            <?php else: ?>
            <div class="info-box fixed">
                <strong>A07 - Troca de Senha Corrigida (MODO CORRIGIDO)</strong>
                O servidor exige e valida a senha atual com password_verify() antes de permitir a alteracao.
            </div>
            <?php endif; ?>

            <div class="card">
                <h2>Trocar Senha</h2>

                <?php if ($pwMsg !== ''): ?>
                    <?php if ($pwMsgType === 'success'): ?>
                        <div style="background:#d4edda;color:#155724;border:1px solid #c3e6cb;padding:12px;border-radius:6px;margin-bottom:16px;">
                            <?= htmlspecialchars($pwMsg) ?>
                        </div>
                    <?php elseif ($pwMsgType === 'warning'): ?>
                        <div style="background:#fff3cd;color:#856404;border:1px solid #ffc107;padding:12px;border-radius:6px;margin-bottom:16px;">
                            <?= htmlspecialchars($pwMsg) ?>
                        </div>
                    <?php else: ?>
                        <div class="alert alert-error"><?= htmlspecialchars($pwMsg) ?></div>
                    <?php endif; ?>
                <?php endif; ?>

                <form method="POST" action="/change-password.php" style="max-width:420px;">

                    <?php if (!isVulnerableMode()): ?>
                    <div style="margin-bottom:12px;">
                        <label style="display:block;margin-bottom:4px;font-weight:600;">Senha Atual *</label>
                        <input type="password" name="current_password" required
                               style="width:100%;padding:8px 10px;border:1px solid #ccc;border-radius:4px;font-size:0.95rem;">
                    </div>
                    <?php else: ?>
                    <div style="margin-bottom:12px;padding:8px 12px;background:#fff3cd;border-left:4px solid #ffc107;border-radius:4px;font-size:0.85rem;color:#856404;">
                        Modo Vulneravel: campo "Senha Atual" omitido.
                    </div>
                    <?php endif; ?>

                    <div style="margin-bottom:12px;">
                        <label style="display:block;margin-bottom:4px;font-weight:600;">Nova Senha *</label>
                        <input type="password" name="new_password" required minlength="6"
                               style="width:100%;padding:8px 10px;border:1px solid #ccc;border-radius:4px;font-size:0.95rem;"
                               placeholder="Minimo 6 caracteres">
                    </div>

                    <div style="margin-bottom:20px;">
                        <label style="display:block;margin-bottom:4px;font-weight:600;">Confirmar Nova Senha *</label>
                        <input type="password" name="confirm_password" required minlength="6"
                               style="width:100%;padding:8px 10px;border:1px solid #ccc;border-radius:4px;font-size:0.95rem;"
                               placeholder="Repita a nova senha">
                    </div>

                    <button type="submit" class="btn btn-primary">Alterar Senha</button>
                    <a href="/dashboard.php" class="btn" style="margin-left:8px;">Cancelar</a>
                </form>
            </div>

        </div>
    </div>
</div>

</body>
</html>
