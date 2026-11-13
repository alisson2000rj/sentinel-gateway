<?php
// Alternância didática entre os modos do laboratório.
require_once __DIR__ . '/../src/session.php';

initSession();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit('Método não permitido.');
}

$token = $_POST['token'] ?? '';
if (!is_string($token) || empty($_SESSION['mode_toggle_token'])
    || !hash_equals($_SESSION['mode_toggle_token'], $token)) {
    http_response_code(403);
    exit('Solicitação de alteração de modo inválida.');
}

$nextMode = isVulnerableMode() ? 'fixed' : 'vulnerable';
if (!setAppMode($nextMode)) {
    http_response_code(500);
    exit('Não foi possível atualizar APP_MODE no arquivo .env.');
}

$returnTo = $_POST['return_to'] ?? '/';
if (!is_string($returnTo) || !str_starts_with($returnTo, '/') || str_starts_with($returnTo, '//')) {
    $returnTo = '/';
}

header('Location: ' . $returnTo, true, 303);
exit;
