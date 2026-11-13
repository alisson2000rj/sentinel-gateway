<?php
// ============================================================
// VULNBOX LAB — Controla o acesso direto a arquivos e diretórios sensíveis
// A01: Broken Access Control — Directory Listing (Index of) & File Exposure
// ============================================================

require_once __DIR__ . '/../src/config.php';

$file = $_GET['file'] ?? $_GET['path'] ?? '';

// Em modo vulnerável, permite Directory Listing (Index of) e leitura de arquivos
if (isVulnerableMode()) {
    $target = $file;
    if (!file_exists($target)) {
        $target = dirname(__DIR__) . '/' . ltrim($file, '/');
    }

    if (file_exists($target) && is_file($target)) {
        header('Content-Type: text/plain; charset=utf-8');
        http_response_code(200);
        echo file_get_contents($target);
        exit;
    } elseif (file_exists($target) && is_dir($target)) {
        header('Content-Type: text/html; charset=utf-8');
        http_response_code(200);
        $cleanPath = htmlspecialchars('/' . ltrim($file, '/'));
        echo "<!DOCTYPE html>\n<html lang=\"pt-BR\"><head><title>Index of " . $cleanPath . "</title></head><body>\n";
        echo "<h1>Index of " . $cleanPath . "</h1>\n<hr><pre>\n";
        echo sprintf("%-30s %-20s %-10s\n", "Nome do Arquivo", "Última Modificação", "Tamanho");
        echo str_repeat("-", 65) . "\n";
        $files = scandir($target);
        foreach ($files as $f) {
            if ($f === '.' || $f === '..') continue;
            $filePath = rtrim($target, '/') . '/' . $f;
            $isDir = is_dir($filePath);
            $modTime = date("Y-m-d H:i:s", filemtime($filePath));
            $size = $isDir ? "-" : filesize($filePath) . " B";
            $displayName = $isDir ? $f . "/" : $f;
            $link = '/' . ltrim($file, '/') . '/' . $f;
            echo sprintf('<a href="%s">%-30s</a> %-20s %-10s' . "\n", htmlspecialchars($link), htmlspecialchars($displayName), $modTime, $size);
        }
        echo "</pre><hr><address>Apache/2.4.68 (Debian) Server at owasp-lab-vulnbox-lab (MODO VULNERÁVEL — Directory Listing Ativo)</address></body></html>";
        exit;
    }

    http_response_code(404);
    header('Content-Type: text/plain; charset=utf-8');
    echo "Arquivo ou diretório não encontrado.";
    exit;
} else {
    // MODO CORRIGIDO — servidor bloqueia o Directory Listing (Options -Indexes)
    http_response_code(403);
    header('Content-Type: text/html; charset=utf-8');
    echo "<!DOCTYPE html><html lang=\"pt-BR\"><head><title>403 Forbidden</title></head><body><h1>Forbidden</h1><p>You don't have permission to access this resource. Directory listing is disabled by server policy (Options -Indexes / MODO CORRIGIDO).</p><hr><address>Apache/2.4.68 (Debian) Server at owasp-lab-vulnbox-lab</address></body></html>";
    exit;
}
