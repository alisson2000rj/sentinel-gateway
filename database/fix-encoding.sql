-- Corrige dados UTF-8 que foram interpretados como latin1 durante uma carga
-- anterior. Execute uma única vez em bancos já inicializados.
SET NAMES utf8mb4;
START TRANSACTION;

UPDATE users
SET name = CONVERT(BINARY CONVERT(name USING latin1) USING utf8mb4)
WHERE HEX(name) REGEXP 'C383|C382';

UPDATE documents
SET
    title = IF(
        HEX(title) REGEXP 'C383|C382',
        CONVERT(BINARY CONVERT(title USING latin1) USING utf8mb4),
        title
    ),
    content = IF(
        HEX(content) REGEXP 'C383|C382',
        CONVERT(BINARY CONVERT(content USING latin1) USING utf8mb4),
        content
    )
WHERE HEX(title) REGEXP 'C383|C382'
   OR HEX(content) REGEXP 'C383|C382';

COMMIT;
