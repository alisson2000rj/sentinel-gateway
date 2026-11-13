<?php
// Requer que $user esteja disponível (via currentUser())
$user = $user ?? currentUser();
?>
<div class="topbar">
    <div class="brand">🛡️ <?= APP_NAME ?></div>
    <nav>
        <a href="/dashboard.php">Dashboard</a>
        <a href="/profile.php?id=<?= $user['id'] ?>">Meu Perfil</a>
        <a href="/document.php?id=<?= $user['id'] ?>">Documentos</a>
        <?php if (in_array($user['role'], ['admin','manager'])): ?>
            <a href="/admin/users.php">Admin</a>
        <?php endif; ?>
        <a href="/security.php">Sessão</a>
        <a href="/logout.php" style="color:#e74c3c;">Sair</a>
    </nav>
</div>
