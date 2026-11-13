<?php
// ============================================================
// VULNBOX LAB — Conexão com o Banco de Dados (PDO)
// Usa prepared statements por padrão
// ============================================================

require_once __DIR__ . '/config.php';

/**
 * Retorna uma instância singleton da conexão PDO.
 * O uso de PDO com prepared statements é a forma CORRIGIDA
 * de prevenir SQL Injection — mas este lab foca em A01/A07.
 */
function getDB(): PDO {
    static $pdo = null;

    if ($pdo === null) {
        $dsn = sprintf(
            'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
            DB_HOST, DB_PORT, DB_NAME
        );

        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];

        try {
            $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        } catch (PDOException $e) {
            // Em produção, nunca exponha detalhes do erro.
            // Aqui exibimos para fins didáticos do laboratório.
            http_response_code(500);
            die('<h2>Erro de conexão com o banco de dados (LAB):</h2><pre>' . $e->getMessage() . '</pre>');
        }
    }

    return $pdo;
}
