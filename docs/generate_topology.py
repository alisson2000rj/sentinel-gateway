import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Configuração da figura (High DPI, estilo dark mode profissional)
fig, ax = plt.subplots(figsize=(14, 9), dpi=300)
fig.patch.set_facecolor('#0d1117')
ax.set_facecolor('#0d1117')

# Remove eixos
ax.axis('off')
ax.set_xlim(0, 100)
ax.set_ylim(0, 100)

# Título Principal
ax.text(50, 95, "Vulnbox Lab — Topologia de Rede & Endereçamento IP",
        fontsize=18, fontweight='bold', color='#58a6ff', ha='center', va='center')
ax.text(50, 91.5, "Arquitetura de Segurança em 3 Camadas com OpenResty WAF",
        fontsize=12, color='#8b949e', ha='center', va='center')

# -------------------------------------------------------------
# 1. CAMADA HOST (Navegador / Máquina Física)
# -------------------------------------------------------------
host_box = patches.FancyBboxPatch((5, 75), 90, 13, boxstyle="round,pad=0.5",
                                  fc='#161b22', ec='#58a6ff', lw=1.5)
ax.add_patch(host_box)
ax.text(8, 83, "[HOST] MAQUINA FISICA / SISTEMA OPERACIONAL HOST",
        fontsize=12, fontweight='bold', color='#58a6ff')
ax.text(8, 78.5, "• Navegador Web: http://localhost:8080/  |  Painel WAF: http://localhost:8080/_gateway/",
        fontsize=10, color='#e6edf3')
ax.text(8, 76, "• IP de Origem no WAF (Bridge Gateways): 172.19.0.1 (backend) / 172.20.0.1 (frontend)",
        fontsize=10, color='#ffa500', fontweight='bold')

# -------------------------------------------------------------
# 2. REDE FRONTEND (frontend-net: 172.20.0.0/16)
# -------------------------------------------------------------
front_net = patches.FancyBboxPatch((5, 43), 42, 27, boxstyle="round,pad=0.5",
                                   fc='#1c2128', ec='#3fb950', lw=1.5, linestyle='--')
ax.add_patch(front_net)
ax.text(7, 66.5, "REDE: frontend-net (Subrede: 172.20.0.0/16)",
        fontsize=11, fontweight='bold', color='#3fb950')
ax.text(7, 64.5, "Gateway da Subrede: 172.20.0.1", fontsize=9, color='#8b949e')

# Container Kali Attacker
kali_box = patches.FancyBboxPatch((8, 46), 36, 16, boxstyle="round,pad=0.4",
                                  fc='#21262d', ec='#da3633', lw=1.5)
ax.add_patch(kali_box)
ax.text(10, 58, "[KALI] kali-attacker", fontsize=12,
        fontweight='bold', color='#f85149')
ax.text(10, 54, "• IP Frontend: 172.20.0.3",
        fontsize=10, color='#e6edf3', fontweight='bold')
ax.text(10, 51, "• Função: Ferramentas & Scripts PenTest",
        fontsize=9, color='#8b949e')
ax.text(10, 48, "• Scripts: /attacks/*.sh", fontsize=9, color='#8b949e')

# -------------------------------------------------------------
# 3. CONTAINER GATEWAY (Dual-Homed / OpenResty WAF)
# -------------------------------------------------------------
gw_box = patches.FancyBboxPatch((37, 12), 26, 26, boxstyle="round,pad=0.6",
                                fc='#1f2937', ec='#f97316', lw=2)
ax.add_patch(gw_box)
ax.text(50, 34, "[WAF] owasp-lab-sentinel-gateway",
        fontsize=13, fontweight='bold', color='#f97316', ha='center')
ax.text(50, 31.5, "(OpenResty / WAF em Lua)",
        fontsize=10, color='#8b949e', ha='center')

gw_info = [
    "Porta Host: 8080:80",
    "IP Frontend: 172.20.0.2",
    "IP Backend : 172.19.0.2",
    "Modo: Active / Passive",
    "6 Regras de Segurança",
    "IP Whitelist & Roles"
]
y_pos = 28
for line in gw_info:
    ax.text(50, y_pos, f"• {line}", fontsize=9, color='#e6edf3', ha='center')
    y_pos -= 2.4

# -------------------------------------------------------------
# 4. REDE BACKEND (backend-net: 172.19.0.0/16 — ISOLADA)
# -------------------------------------------------------------
back_net = patches.FancyBboxPatch((53, 43), 42, 27, boxstyle="round,pad=0.5",
                                  fc='#1c2128', ec='#a371f7', lw=1.5, linestyle='--')
ax.add_patch(back_net)
ax.text(55, 66.5, "REDE: backend-net (Subrede: 172.19.0.0/16)",
        fontsize=11, fontweight='bold', color='#a371f7')
ax.text(55, 64.5, "Gateway da Subrede: 172.19.0.1 (Isolada do Host)",
        fontsize=9, color='#8b949e')

# Container Web App
web_box = patches.FancyBboxPatch((56, 54), 36, 9.5, boxstyle="round,pad=0.4",
                                 fc='#21262d', ec='#58a6ff', lw=1.2)
ax.add_patch(web_box)
ax.text(58, 60.5, "[WEB] owasp-lab-vunlbox-lab",
        fontsize=11, fontweight='bold', color='#58a6ff')
ax.text(58, 57.5, "• IP Backend: 172.19.0.4  |  Porta Interna: 80",
        fontsize=9.5, color='#e6edf3')
ax.text(58, 55.2, "• Servidor: PHP 8.2 + Apache (Aplicação Vulnerável)",
        fontsize=8.5, color='#8b949e')

# Container MySQL
db_box = patches.FancyBboxPatch((56, 45), 36, 7.5, boxstyle="round,pad=0.4",
                                fc='#21262d', ec='#3fb950', lw=1.2)
ax.add_patch(db_box)
ax.text(58, 50, "[DB] vulnbox-lab-mysql", fontsize=11,
        fontweight='bold', color='#3fb950')
ax.text(58, 47, "• IP Backend: 172.19.0.3  |  Porta Interna: 3306",
        fontsize=9.5, color='#e6edf3')

# -------------------------------------------------------------
# SETAS E FLUXO DE CONEXÕES
# -------------------------------------------------------------
# Host -> Gateway
ax.annotate("", xy=(50, 38.5), xytext=(50, 75),
            arrowprops=dict(arrowstyle="->", color='#58a6ff', lw=2, mutation_scale=15))
ax.text(51, 68, "HTTP Request (localhost:8080)",
        fontsize=9, color='#58a6ff', fontweight='bold')

# Kali -> Gateway
ax.annotate("", xy=(37, 25), xytext=(26, 46),
            arrowprops=dict(arrowstyle="->", color='#da3633', lw=2, mutation_scale=15))
ax.text(22, 33, "Ataques PenTest\n(172.20.0.3 -> 172.20.0.2)",
        fontsize=8.5, color='#da3633', fontweight='bold')

# Gateway -> Web
ax.annotate("", xy=(64, 54), xytext=(63, 38.5),
            arrowprops=dict(arrowstyle="->", color='#3fb950', lw=2, mutation_scale=15))
ax.text(65, 41.5, "Proxy Inspeccionado\n(172.19.0.2 -> 172.19.0.4)",
        fontsize=8.5, color='#3fb950', fontweight='bold')

# Web -> MySQL
ax.annotate("", xy=(74, 52.5), xytext=(74, 54),
            arrowprops=dict(arrowstyle="<->", color='#a371f7', lw=1.5, mutation_scale=10))

# Rodapé
ax.text(50, 4, "Sentinel Gateway & Vulnbox Lab Environment",
        fontsize=9, color='#6e7681', ha='center')

plt.tight_layout()
plt.savefig('docs/topologia.png',
            facecolor=fig.get_facecolor(), edgecolor='none')
print("Topologia salva com sucesso em docs/topologia.png")
