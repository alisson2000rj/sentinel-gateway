<?php
// Entrada da área administrativa: impede que o Apache liste os arquivos
// existentes no diretório /admin/.
require_once __DIR__ . '/../../src/session.php';
require_once __DIR__ . '/../../src/permissions.php';

requireLogin();

// CORRIGIDO — a rota /admin/ também aplica autorização no servidor, antes
// de encaminhar para qualquer página administrativa.
if (isFixedMode()) {
    requireAdmin();
}

// VULNERÁVEL — um usuário autenticado que conhece a URL ainda alcança a
// demonstração de escalada vertical em users.php.
header('Location: /admin/users.php', true, 302);
exit;
