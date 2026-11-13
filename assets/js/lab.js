// ============================================================
// VULNBOX LAB — Scripts de laboratório
// ============================================================

// Exibe um aviso quando o usuário acessa uma área protegida
// diretamente pela URL (demonstração de escalada vertical)
function highlightVuln(elementId, message) {
    const el = document.getElementById(elementId);
    if (el) {
        el.classList.add('vuln-highlight');
        el.insertAdjacentHTML('afterbegin',
            '<div class="alert alert-error">⚠️ VULNERABILIDADE DETECTADA: ' + message + '</div>'
        );
    }
}

// Simula tentativas de força bruta (apenas demonstração local)
let bruteCount = 0;
function simulateBruteForce() {
    bruteCount++;
    const el = document.getElementById('brute-counter');
    if (el) el.textContent = bruteCount;
}

// Copia texto para a área de transferência
function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        alert('Copiado: ' + text);
    });
}
