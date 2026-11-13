<?php
// ============================================================
// VULNBOX LAB — Documento
// A01: Broken Access Control — IDOR em recursos
// ============================================================

require_once __DIR__ . '/../src/config.php';
require_once __DIR__ . '/../src/session.php';
require_once __DIR__ . '/../src/permissions.php';
require_once __DIR__ . '/../src/database.php';
require_once __DIR__ . '/../src/logger.php';
require_once __DIR__ . '/../src/auth.php';

// Handler de Path Traversal (sem proteção no modo vulnerável)
$rawId = $_GET['id'] ?? $_GET['file'] ?? $_GET['path'] ?? null;
if (is_string($rawId) && (str_contains($rawId, '..') || str_contains($rawId, '/'))) {
    if (isVulnerableMode()) {
        $targetFile = $rawId;
        if (!file_exists($targetFile)) {
            $targetFile = dirname(__DIR__) . '/' . ltrim($rawId, '/');
        }
        if (!file_exists($targetFile)) {
            $targetFile = dirname(__DIR__) . '/public/' . ltrim($rawId, '/');
        }

        if (file_exists($targetFile) && is_file($targetFile)) {
            header('Content-Type: text/plain; charset=utf-8');
            http_response_code(200);
            echo file_get_contents($targetFile);
            exit;
        } elseif (file_exists($targetFile) && is_dir($targetFile)) {
            header('Content-Type: text/html; charset=utf-8');
            http_response_code(200);
            $cleanPath = htmlspecialchars('/' . ltrim($rawId, '/'));
            echo "<!DOCTYPE html>\n<html lang=\"pt-BR\"><head><title>Index of " . $cleanPath . "</title></head><body>\n";
            echo "<h1>Index of " . $cleanPath . "</h1>\n<hr><pre>\n";
            echo sprintf("%-30s %-20s %-10s\n", "Nome do Arquivo", "Última Modificação", "Tamanho");
            echo str_repeat("-", 65) . "\n";
            foreach (scandir($targetFile) as $f) {
                if ($f === '.' || $f === '..') continue;
                $filePath = rtrim($targetFile, '/') . '/' . $f;
                $isDir = is_dir($filePath);
                $modTime = date("Y-m-d H:i:s", filemtime($filePath));
                $size = $isDir ? "-" : filesize($filePath) . " B";
                $displayName = $isDir ? $f . "/" : $f;
                $link = '/' . ltrim($rawId, '/') . '/' . $f;
                echo sprintf('<a href="%s">%-30s</a> %-20s %-10s' . "\n", htmlspecialchars($link), htmlspecialchars($displayName), $modTime, $size);
            }
            echo "</pre><hr><address>Apache/2.4.68 (Debian) Server at owasp-lab-vulnbox-lab (MODO VULNERÁVEL — Directory Listing Ativo)</address></body></html>";
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

$db = getDB();

$docId = (int)($rawId ?? 1);
$stmt = $db->prepare('SELECT d.*, u.username as owner_username FROM documents d JOIN users u ON d.user_id = u.id WHERE d.id = ?');
$stmt->execute([$docId]);
$document = $stmt->fetch();

$allowed = false;
if ($document) {
    if (isVulnerableMode()) {
        $allowed = true;
    } else {
        $allowed = canAccessDocument($document);
    }
}

if ($allowed && $document) {
    logAudit($me['id'], 'VIEW_DOCUMENT', "Acessou documento id=$docId (dono: {$document['user_id']})", getClientIP());
}

// Lista todos os documentos (para navegação no lab)
$allDocs = $db->query('SELECT d.id, d.title, d.user_id, u.username FROM documents d JOIN users u ON d.user_id=u.id ORDER BY d.id')->fetchAll();
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Documento — <?= APP_NAME ?></title>
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
                <strong>🔴 A01 — IDOR em Documentos (MODO VULNERÁVEL)</strong>
                <b>Falha:</b> o servidor retorna qualquer documento pelo ID sem verificar o dono.<br>
                <b>Exploração:</b> altere <code>?id=</code> de 1 a <?= count($allDocs) ?> para acessar documentos de outros usuários.<br>
                <b>Impacto:</b> vazamento de documentos confidenciais e de gestão.
            </div>
            <?php else: ?>
            <div class="info-box fixed">
                <strong>🟢 A01 — IDOR Corrigido em Documentos</strong>
                O servidor verifica a propriedade de cada documento antes de exibi-lo.
            </div>
            <?php endif; ?>

            <!-- Navegação entre documentos -->
            <div class="card">
                <h2>📂 Navegar entre documentos (demonstração IDOR)</h2>
                <div style="display:flex;flex-wrap:wrap;gap:8px;">
                    <?php foreach ($allDocs as $d): ?>
                        <a href="/document.php?id=<?= $d['id'] ?>"
                           class="btn btn-sm <?= $d['id'] == $docId ? 'btn-danger' : 'btn-primary' ?>">
                            Doc #<?= $d['id'] ?> (<?= htmlspecialchars($d['username']) ?>)
                        </a>
                    <?php endforeach; ?>
                </div>
                <p style="margin-top:10px;font-size:0.85rem;color:#888;">
                    Você é: <strong><?= htmlspecialchars($me['username']) ?></strong>.
                    Documentos de outros usuários devem ser bloqueados no modo corrigido.
                </p>
            </div>

            <!-- Conteúdo do documento -->
            <?php if (!$document): ?>
                <div class="card">
                    <div class="alert alert-error">Documento id=<?= $docId ?> não encontrado.</div>
                </div>

            <?php elseif (!$allowed): ?>
                <div class="card">
                    <div class="alert alert-error">
                        🚫 <strong>Acesso Negado (403)</strong><br>
                        Este documento pertence ao usuário <strong><?= htmlspecialchars($document['owner_username']) ?></strong>.
                        Você não tem permissão para visualizá-lo.<br>
                        <small>CORRIGIDO: o servidor bloqueou o acesso.</small>
                    </div>
                </div>

            <?php else: ?>
                <div class="card">
                    <h2>
                        📄 <?= htmlspecialchars($document['title']) ?>
                        <?php if ((int)$document['user_id'] !== (int)$me['id']): ?>
                            &nbsp;<span class="badge badge-vuln">⚠️ Documento de outro usuário</span>
                        <?php endif; ?>
                    </h2>

                    <table style="margin-bottom:16px;">
                        <tr><td style="width:120px;"><strong>ID</strong></td><td><?= $document['id'] ?></td></tr>
                        <tr><td><strong>Proprietário</strong></td><td><?= htmlspecialchars($document['owner_username']) ?> (user_id=<?= $document['user_id'] ?>)</td></tr>
                        <tr><td><strong>Criado em</strong></td><td><?= htmlspecialchars($document['created_at']) ?></td></tr>
                    </table>

                    <div style="background:#f8f9fa;border-radius:8px;padding:16px;white-space:pre-wrap;font-family:monospace;font-size:0.88rem;">
                        <?= htmlspecialchars($document['content']) ?>
                    </div>

                    <?php if ((int)$document['user_id'] !== (int)$me['id'] && isVulnerableMode()): ?>
                    <div class="alert alert-error" style="margin-top:16px;">
                        ⚠️ <strong>VULNERABILIDADE EXPLORADA:</strong>
                        Você leu um documento confidencial de <strong><?= htmlspecialchars($document['owner_username']) ?></strong>.
                    </div>
                    <?php endif; ?>
                </div>
            <?php endif; ?>

        </div>
    </div>
</div>
</body>
</html>
