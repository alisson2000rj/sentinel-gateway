<?php
$user = $user ?? currentUser();
$current = basename($_SERVER['PHP_SELF']);
?>
<div class="sidebar">
    <div class="card">
        <strong><?= htmlspecialchars($user['name']) ?></strong><br>
        <small style="color:#888;"><?= htmlspecialchars($user['username']) ?></small><br><br>
        <?php
        echo match($user['role']) {
            'admin'   => '<span class="badge badge-admin">ADMIN</span>',
            'manager' => '<span class="badge badge-manager">MANAGER</span>',
            default   => '<span class="badge badge-user">USER</span>',
        };
        $clientIp = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
        echo ' <span class="badge" style="background:#21262d;color:#58a6ff;border:1px solid #30363d;font-family:monospace;" title="IP de Origem">IP: ' . htmlspecialchars($clientIp) . '</span>';
        ?>
        <div style="margin-top:8px;font-size:0.75rem;color:#777;word-break:break-all;">
            <strong>Sessão (PHPSESSID):</strong><br>
            <code style="font-size:0.72rem;color:#2c3e50;background:#eef2f7;padding:2px 4px;border-radius:3px;display:inline-block;margin-top:2px;"><?= htmlspecialchars(session_id()) ?></code>
        </div>
        <hr style="margin:12px 0;border-color:#eee;">
        <ul>
            <li><a href="/dashboard.php" <?= $current==='dashboard.php'?'class="active"':'' ?>>🏠 Dashboard</a></li>
            <li><a href="/profile.php?id=<?= $user['id'] ?>" <?= $current==='profile.php'?'class="active"':'' ?>>👤 Meu Perfil</a></li>
            <li><a href="/document.php?id=<?= $user['id'] ?>" <?= $current==='document.php'?'class="active"':'' ?>>📄 Documentos</a></li>
            <li><a href="/security.php" <?= $current==='security.php'?'class="active"':'' ?>>🔒 Sessão/Segurança</a></li>

            <!-- ADICIONADO: troca de senha — A07 (vulnerável: sem verificar senha atual / corrigido: exige password_verify) -->
            <li><a href="/change-password.php" <?= $current==='change-password.php'?'class="active"':'' ?>>🔑 Trocar Senha</a></li>

            <?php if ($user['role'] === 'admin' || $user['role'] === 'manager'): ?>
            <li class="sep"></li>
            <li><a href="/admin/users.php">👥 Gerenciar Usuários</a></li>
            <li><a href="/admin/logs.php">📋 Logs de Auditoria</a></li>
            <li><a href="/admin/settings.php">⚙️ Configurações</a></li>
            <?php elseif (isVulnerableMode()): ?>
            <!-- VULNERÁVEL: links admin ocultos na UI, mas endpoints acessíveis diretamente -->
            <li class="sep"></li>
            <li><small style="color:#aaa;padding:8px 10px;display:block;">
                💡 <em>Lab: acesse /admin/ diretamente pela URL</em>
            </small></li>
            <?php endif; ?>
            <li class="sep"></li>
            <li><a href="/logout.php" style="color:#e74c3c;">🚪 Sair</a></li>
        </ul>
    </div>
</div>
