# 🚀 Minha Config do NixOS

> *"A humanidade questionou. O computador calculou. Milhões de anos se passaram. A resposta ecoou pelo cosmos: '42'. Enquanto isso, no porão, um dev descobriu que nixos-rebuild switch resolve quase tudo. Quase."*

Bem-vindo à minha configuração do NixOS! Este é meu setup pessoal rodando GNOME com tema Gruvbox, porque dark mode é vida. 🌙

## 📊 O Setup

**Hardware:**
- **CPU:** AMD Ryzen 5 5600X (12 threads de pura beleza)
- **GPU:** NVIDIA GeForce GTX 1060 3GB *(sim, ela ainda tá viva e lutando bravamente em 2026)*
- **RAM:** 32GB (porque fechar abas do Chrome não é uma opção)
- **Storage:** 3TB total (1TB SSD + 2x 1TB HDD)
- **Mobo:** ASRock B450M Steel Legend

**Software:**
- **OS:** NixOS 25.11 (Xantusia)
- **Kernel:** Linux 6.18.3 (sempre no latest)
- **DE:** GNOME 49 com Wayland
- **DM:** SDDM com suporte a Wayland
- **Shell:** Fish (porque vida é curta demais pra bash)

## ✨ Features Principais

### 🎨 Visual
- **Tema Gruvbox** em absolutamente tudo (GTK3, GTK4, GNOME)
- Fontes **JetBrains Mono Nerd Font** porque programador tem que ter estilo
- Extensões do GNOME: Blur My Shell, Dash to Dock, User Themes
- SDDM com tema Breeze (pode mudar depois se quiser)

### 🛠️ Desenvolvimento
- **PostgreSQL 15** configurado em modo DEV (trust, sem senha - **NÃO USE EM PRODUÇÃO**)
- Bancos pré-criados: `mydatabase` e `anorak`
- **direnv + nix-direnv** para ambientes de desenvolvimento isolados
- **Node.js** porque JavaScript domina o mundo, querendo ou não
- **VSCode** como IDE principal

### 🎮 Apps & Produtividade
- **Ghostty** (terminal moderno e rápido)
- **Firefox** (pré-instalado)
- **Flatpak** habilitado com Flathub (para aqueles apps que o Nix não tem)
- **Discord/Vesktop** e **Element** para comunicação
- **Spotify** para código com trilha sonora
- **Obsidian** para organizar a bagunça mental
- **VLC** porque ele toca qualquer coisa

### 🐟 Fish Shell Setup
Plugins configurados:
- `done` - notificações quando comandos longos terminam
- `fzf-fish` - busca fuzzy em tudo
- `forgit` - git interativo e bonito
- `hydro` - prompt minimalista e rápido
- `grc` - colorização de comandos

### 🎯 NVIDIA Drivers
- Drivers proprietários (stable)
- Modesetting habilitado
- Suporte a 32-bit (para aqueles jogos antigos)

## 📁 Estrutura do Repo

```
.
├── configuration.nix           # Config principal
├── hardware-configuration.nix  # Config de hardware (gerado automaticamente)
├── disks.nix                   # Configuração de discos (criar baseado no .example)
└── README.md                   # Você está aqui! 👋
```

## 🚀 Como Usar

### Instalação Limpa

1. Clone este repo:
```bash
git clone https://github.com/seu-usuario/nixos-config.git /etc/nixos
cd /etc/nixos
```

2. **IMPORTANTE:** Crie seu `disks.nix` baseado no seu sistema (ou use o exemplo)

3. Gere seu `hardware-configuration.nix`:
```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

4. Edite o `configuration.nix` e ajuste:
   - Nome do usuário (troque `anorak` pelo seu)
   - Hostname (linha 28)
   - Bancos de dados PostgreSQL (se necessário)

5. Rebuild:
```bash
sudo nixos-rebuild switch
```

### Atualizando o Sistema

```bash
# Atualizar canais
sudo nix-channel --update

# Rebuild
sudo nixos-rebuild switch

# Ou tudo de uma vez
sudo nix-channel --update && sudo nixos-rebuild switch
```

### Limpando Gerações Antigas

```bash
# Listar gerações
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Deletar gerações antigas (mantém as últimas 5 automaticamente no boot)
sudo nix-collect-garbage -d

# Ou deletar gerações específicas
sudo nix-env --delete-generations 1 2 3 --profile /nix/var/nix/profiles/system
```

## 🔧 Customizações Interessantes

### Home Manager
A config usa Home Manager integrado ao NixOS para gerenciar configs de usuário. Tudo do tema Gruvbox, fontes e configurações do GNOME está no bloco `home-manager.users.anorak`.

### PostgreSQL em Modo DEV
O PostgreSQL está configurado em modo **trust** (sem senha). Isso é ótimo para desenvolvimento local, mas **NUNCA** use isso em produção ou em uma máquina exposta à internet.

### Flatpak Auto-Setup
O systemd service `flatpak-repo` adiciona automaticamente o Flathub na primeira inicialização.

### Limite de Boot
O bootloader mantém apenas as últimas 5 gerações (configurável em `boot.loader.systemd-boot.configurationLimit`).

## 💡 Dicas

- **NTFS Support:** Habilitado caso você tenha dual-boot com Windows
- **Kernel:** Sempre usando a versão latest (pode mudar para LTS se preferir estabilidade)
- **Nvidia:** Se tiver problemas com suspend/hibernate, ative `powerManagement.enable = true` no bloco nvidia
- **Wayland:** Funciona perfeitamente com GNOME e NVIDIA nos drivers recentes

## 🤝 Contribuindo

Achou algo interessante ou tem sugestões? Sinta-se livre para abrir uma issue ou PR! Este é um projeto pessoal, mas adoro aprender com a comunidade.

## 📝 Notas

- Esta config é para uso pessoal, mas está pública para ajudar outros usuários de NixOS
- Baseado em NixOS 25.11 (pode funcionar em versões anteriores com ajustes)
- Testado apenas no meu hardware (mas deve funcionar em qualquer máquina com ajustes mínimos)

## 📜 Licença

MIT - Faça o que quiser com isso! 🎉

---

*Feito com ❤️ e muito café ☕ em NixOS*

**P.S.:** Se você está lendo isso e pensando "cara, essa GTX 1060 em 2026?", sim amigo, ela ainda aguenta. Não julga. 😅
