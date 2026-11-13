<?php
require_once __DIR__ . '/../src/session.php';
require_once __DIR__ . '/../src/logger.php';
require_once __DIR__ . '/../src/auth.php';

initSession();

if (!empty($_SESSION['user_id'])) {
    logAudit($_SESSION['user_id'], 'LOGOUT', 'Logout realizado', getClientIP());
}

destroySession();
header('Location: /login.php');
exit;
