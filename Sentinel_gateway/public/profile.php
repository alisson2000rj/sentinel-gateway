<?php
// ============================================================
// VULNBOX LAB — Perfil do Usuário
// A01: Broken Access Control — IDOR / Escalada Horizontal
// ============================================================

require_once __DIR__ . '/../src/config.php';
require_once __DIR__ . '/../src/session.php';
require_once __DIR__ . '/../src/permissions.php';
require_once __DIR__ . '/../src/database.php';
require_once __DIR__ . '/../src/logger.php';
require_once __DIR__ . '/../src/auth.php';

// Handler de Path Traversal em profile.php (sem proteção no modo vulnerável)
$rawId = $_GET['id'] ?? $_GET['file'] ?? $_GET['path'] ?? null;
if (is_string($rawId) && (str_contains($rawId, '..') || str_contains($rawId, '/'))) {
    if (isVulnerableMode()) {
        $targetFile = $rawId;
        if (!file_exists($targetFile)) {
            $targetFile = dirname(__DIR__) . '/' . ltrim($rawId, '/');
        }
        if (file_exists($targetFile) && is_file($targetFile)) {
            header('Content-Type: text/plain; charset=utf-8');
            http_response_code(200);
            echo file_get_contents($targetFile);
            exit;
        } elseif (file_exists($targetFile) && is_dir($targetFile)) {
            header('Content-Type: text/plain; charset=utf-8');
            http_response_code(200);
            echo "Exposição de Diretório (" . htmlspecialchars($rawId) . "):\n";
            foreach (scandir($targetFile) as $f) {
                if ($f !== '.' && $f !== '..') {
                    echo "- " . $f . "\n";
                }
            }
            exit;
        }

        http_response_code(404);
        header('Content-Type: text/plain; charset=utf-8');
        echo "Arquivo não encontrado.";
        exit;
    } else {
        http_response_code(403);
        header('Content-Type: text/plain; charset=utf-8');
        echo "🚫 HTTP 403 Forbidden: Path Traversal bloqueado pelo servidor (MODO CORRIGIDO).";
        exit;
    }
}

requireLogin();
$me = currentUser();

$targetId = (int)($rawId ?? $me['id']);
if (isVulnerableMode()) {
    $allowed = true;
} else {
    $allowed = canAccessProfile($targetId);
}

if (!$allowed) {
    http_response_code(403);
    $db = null;
}

$profile = null;
if ($allowed) {
    $db   = getDB();
    $stmt = $db->prepare('SELECT id, username, name, email, role, status, created_at FROM users WHERE id = ?');
    $stmt->execute([$targetId]);
    $profile = $stmt->fetch();

    if ($profile) {
        logAudit($me['id'], 'VIEW_PROFILE', "Acessou perfil id=$targetId", getClientIP());
    }
}

// Busca lista de usuários para navegação (laboratório)
$db2   = getDB();
$users = $db2->query('SELECT id, username, name, role FROM users ORDER BY id')->fetchAll();
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Perfil — <?= APP_NAME ?></title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body class="<?= modeClass() ?>">

<?php include __DIR__ . '/partials/topbar.php'; ?>
<?= modeBanner() ?>

<div class="container">
    <div class="layout">
        <?php include __DIR__ . '/partials/sidebar.php'; ?>

        <div class="content">

            <!-- ====================================================
                 EXPLICAÇÃO DIDÁTICA DA VULNERABILIDADE
                 ==================================================== -->
            <?php if (isVulnerableMode()): ?>
            <div class="info-box vuln">
                <strong>🔴 A01 — IDOR / Escalada Horizontal (MODO VULNERÁVEL)</strong>
                <b>Recurso protegido:</b> dados pessoais de cada usuário.<br>
                <b>Falha:</b> o endpoint aceita qualquer <code>?id=</code> sem verificar se pertence ao usuário logado.<br>
                <b>Exploração:</b> altere o <code>?id=</code> na URL para ver perfis de outros usuários.<br>
                <b>Impacto:</b> vazamento de dados pessoais, e-mail, papel e status de qualquer conta.<br>
                <b>Correção:</b> ativar <code>APP_MODE=fixed</code> — o servidor valida a propriedade do recurso.
            </div>
            <?php else: ?>
            <div class="info-box fixed">
                <strong>🟢 A01 — IDOR Corrigido (MODO CORRIGIDO)</strong>
                O servidor verifica se o usuário tem permissão antes de exibir o perfil.
                Usuários comuns só veem o próprio perfil. Admin e Manager podem ver todos.
            </div>
            <?php endif; ?>

            <!-- ====================================================
                 NAVEGAÇÃO ENTRE PERFIS (para demonstrar IDOR)
                 ==================================================== -->
            <div class="card">
                <h2>🔍 Navegar entre perfis (demonstração IDOR)</h2>
                <div style="display:flex;flex-wrap:wrap;gap:8px;">
                    <?php foreach ($users as $u): ?>
                        <a href="/profile.php?id=<?= $u['id'] ?>"
                           class="btn btn-sm <?= $u['id'] == $targetId ? 'btn-danger' : 'btn-primary' ?>">
                            <?= htmlspecialchars($u['username']) ?> (id=<?= $u['id'] ?>)
                        </a>
                    <?php endforeach; ?>
                </div>
                <p style="margin-top:10px;font-size:0.85rem;color:#888;">
                    ↑ Você está logado como <strong><?= htmlspecialchars($me['username']) ?></strong> (id=<?= $me['id'] ?>).
                    Clique em outro usuário e observe se o acesso é permitido.
                </p>
            </div>

            <!-- ====================================================
                 RESULTADO DO ACESSO
                 ==================================================== -->
            <?php if (!$allowed): ?>
                <div class="card">
                    <div class="alert alert-error">
                        🚫 <strong>Acesso Negado (403)</strong><br>
                        Você não tem permissão para visualizar este perfil.
                        <br><small>CORRIGIDO: o servidor bloqueou o acesso ao id=<?= $targetId ?>.</small>
                    </div>
                </div>

            <?php elseif (!$profile): ?>
                <div class="card">
                    <div class="alert alert-error">Usuário id=<?= $targetId ?> não encontrado.</div>
                </div>

            <?php else: ?>
                <div class="card">
                    <h2>
                        👤 Perfil: <?= htmlspecialchars($profile['name']) ?>
                        <?php if ($profile['id'] != $me['id']): ?>
                            &nbsp;<span class="badge badge-vuln">⚠️ Perfil de outro usuário</span>
                        <?php endif; ?>
                    </h2>

                    <table>
                        <tr><th style="width:160px;">Campo</th><th>Valor</th></tr>
                        <tr><td>ID</td><td><?= $profile['id'] ?></td></tr>
                        <tr><td>Usuário</td><td><?= htmlspecialchars($profile['username']) ?></td></tr>
                        <tr><td>Nome</td><td><?= htmlspecialchars($profile['name']) ?></td></tr>
                        <tr><td>E-mail</td><td><?= htmlspecialchars($profile['email']) ?></td></tr>
                        <tr><td>Papel</td><td><?= htmlspecialchars($profile['role']) ?></td></tr>
                        <tr><td>Status</td><td><?= htmlspecialchars($profile['status']) ?></td></tr>
                        <tr><td>Criado em</td><td><?= htmlspecialchars($profile['created_at']) ?></td></tr>
                    </table>

                    <?php if ($profile['id'] != $me['id'] && isVulnerableMode()): ?>
                    <div class="alert alert-error" style="margin-top:16px;">
                        ⚠️ <strong>VULNERABILIDADE EXPLORADA:</strong>
                        Você acessou os dados do usuário <strong><?= htmlspecialchars($profile['username']) ?></strong>
                        (id=<?= $profile['id'] ?>) sem ser esse usuário. Isso é IDOR.
                    </div>
                    <?php endif; ?>
                </div>
            <?php endif; ?>

        </div>
    </div>
</div>
</body>
</html>
