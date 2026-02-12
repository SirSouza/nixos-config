<details>
<summary>Documentação em Português BR</summary>

# 🚀 Minha Configuração NixOS

> _"A humanidade questionou. O computador calculou. Milhões de anos se passaram. A resposta ecoou pelo cosmos: '42'. Enquanto isso, no porão, um dev descobriu que `nixos-rebuild switch` resolve quase tudo. Quase."_

Bem-vindo à minha configuração do NixOS! Este é meu setup pessoal rodando GNOME e a versão mais recente do kernel, organizado de forma modular para fácil manutenção.

---

## 📊 O Setup

### Hardware

- **CPU:** AMD Ryzen 5 5600X
- **GPU:** NVIDIA GeForce GTX 1060 3GB _(sim, ainda está viva e lutando bravamente em 2026)_
- **RAM:** 32GB (porque fechar abas do Chrome não é uma opção)
- **Armazenamento:** 3TB total (1TB SSD + 2× 1TB HDD)
- **Placa-mãe:** ASRock B450M Steel Legend

### Software

- **SO:** NixOS 26.05 (Yarara)
- **Kernel:** Linux 6.18.4 (sempre o mais recente)
- **DE:** GNOME 49 (Wayland)
- **DM:** SDDM com suporte Wayland
- **Shell:** Fish (a vida é curta demais para bash)

---

## ✨ Recursos Principais

### 🎨 Visual

- **Tema Gruvbox** em todo lugar (GTK3, GTK4, GNOME)
- **JetBrains Mono Nerd Font** — porque desenvolvedores precisam de estilo
- Extensões do GNOME: Dash to Dock, User Themes, Blur My Shell
- SDDM com tema customizado (where_is_my_sddm_theme)

### 🛠️ Desenvolvimento

- **PostgreSQL 15** configurado em modo DEV (autenticação trust, sem senha — **NÃO USE EM PRODUÇÃO**)
- Bancos de dados pré-criados: `mydatabase` e `anorak`
- **direnv + nix-direnv** para ambientes de desenvolvimento isolados
- **Node.js + Yarn** para desenvolvimento web
- **VS Code, Zed Editor, Helix, Neovim** — escolha sua arma
- **LSPs:** nixd, clang-tools, lua-language-server, pyright
- **Rust, GCC, Make** prontos para usar

### 🎮 Gaming & Entretenimento

- **Steam** com suporte 32-bit
- **Lutris** para jogos de várias plataformas
- **PCSX2** (emulador PS2)
- **RPCS3** (emulador PS3)
- **Wine (Wayland)** para jogos Windows
- **Bottles** para gerenciar prefixes Wine

### 🎮 Apps & Produtividade

- **Ghostty** (terminal moderno e rápido)
- **Cool Retro Term** (porque às vezes queremos hackear como nos anos 80)
- **Firefox** (pré-instalado)
- **Flatpak** habilitado com Flathub
- **Discord** para comunicação
- **Spotify** para trilhas sonoras de programação
- **Obsidian** para organizar o caos mental
- **Anytype** via AppImage
- **VLC** — reproduz tudo
- **Jellyfin** (servidor de mídia + cliente desktop)

### 🐟 Configuração do Fish Shell

Plugins configurados:

- `done` — notificações quando comandos demorados terminam
- `fzf-fish` — busca fuzzy em todo lugar
- `forgit` — workflow Git interativo e limpo
- `hydro` — prompt minimalista e rápido
- `grc` — colorização de saída de comandos

### 🎯 Drivers NVIDIA

- Drivers proprietários (stable)
- Modesetting habilitado
- Suporte 32-bit (para jogos legados)
- CUDA habilitado (para OBS Studio)

### 🖥️ Virtualização

- **libvirtd + QEMU/KVM** configurado
- **virt-manager** para interface gráfica
- TPM virtual (swtpm) habilitado
- Rede NAT configurada (192.168.122.0/24)

---

## 🔐 Secure Boot com Lanzaboote (Flakes)

**Tutorial completo aqui** = [Guia de Configuração](./nixos_secureboot_tutorial.md)

Esta configuração usa **lanzaboote** para habilitar **UEFI Secure Boot** mantendo o sistema totalmente declarativo e compatível com **Nix flakes**.

### Por que Lanzaboote?

- Funciona perfeitamente com **systemd-boot**
- Configuração de Secure Boot totalmente declarativa
- Ideal para sistemas NixOS **baseados em flake**
- Assina kernels e artefatos de boot automaticamente

### Características Principais

- Secure Boot **habilitado e aplicado**
- Machine Owner Key (MOK) personalizada gerenciada pelo NixOS
- Compatível com rollbacks e gerações do sistema
- Não requer shim

### Visão Geral da Configuração

- Chaves do Secure Boot são geradas e gerenciadas declarativamente
- systemd-boot é usado como bootloader
- lanzaboote assina binários EFI automaticamente durante rebuilds
- Flakes são usados como ponto de entrada para configuração do sistema

### Observações

- Após o registro inicial das chaves, o Secure Boot permanece habilitado entre rebuilds
- Se as configurações do firmware forem redefinidas, as chaves podem precisar ser registradas novamente
- Esta configuração é ideal para laptops e desktops que requerem Secure Boot (ex: dual-boot com Windows)

> ⚠️ Importante: Uma vez que o Secure Boot está habilitado e aplicado, kernels não assinados **não irão inicializar**.

---

## 📁 Estrutura do Repositório

```
/etc/nixos/
├── flake.nix                   # Flake entry point
├── flake.lock                  # Flake lock file
├── configuration.nix           # Main config (apenas imports!)
├── hardware-configuration.nix  # Auto-generated hardware config
├── disks.nix                   # Disk layout configuration
├── home.nix                    # Home Manager user configuration
├── modules/
│   ├── boot.nix               # Bootloader, kernel, secure boot
│   ├── system.nix             # Hostname, locale, timezone, nix settings
│   ├── hardware.nix           # NVIDIA, graphics, sound
│   ├── desktop.nix            # GNOME, SDDM, Qt configuration
│   ├── services.nix           # PostgreSQL, Jellyfin, printing, flatpak
│   ├── virtualization.nix     # libvirt, QEMU, virt-manager
│   ├── programs.nix           # System programs (fish, direnv, obs, etc)
│   ├── users.nix              # User account configuration
│   └── packages.nix           # All system packages
└── README.md                   # You are here 👋
```

### 🎯 Vantagens da Estrutura Modular

✅ **Organização clara** — cada arquivo tem um propósito específico  
✅ **Fácil manutenção** — quer mudar algo do GNOME? Vai direto no `modules/desktop.nix`  
✅ **Reutilizável** — pode copiar módulos para outras máquinas  
✅ **Versionado** — histórico limpo no git  
✅ **Escalável** — fácil adicionar novos módulos sem bagunçar

---

## 🚀 Como Usar

### Instalação do Zero

1. Clone este repositório:

```bash
git clone https://github.com/SirSouza/nixos-config.git /etc/nixos
cd /etc/nixos
```

2. **IMPORTANTE:** Crie seu `disks.nix` de acordo com seu sistema

3. Gere sua configuração de hardware:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

4. Edite os módulos relevantes:

- `modules/users.nix` — substitua `anorak` pelo seu usuário
- `modules/system.nix` — ajuste hostname, timezone, locale
- `modules/services.nix` — configure bancos de dados PostgreSQL (se necessário)
- `modules/packages.nix` — adicione/remova pacotes conforme necessário

5. Recompile o sistema com flakes:

```bash
sudo nixos-rebuild switch --flake /etc/nixos
```

---

### Atualizando o Sistema

```bash
# Atualizar flake inputs
cd /etc/nixos
nix flake update

# Rebuild com as atualizações
sudo nixos-rebuild switch --flake /etc/nixos

# Ou de qualquer lugar
sudo nixos-rebuild switch --flake /etc/nixos
```

---

### Limpando Gerações Antigas

```bash
# Listar gerações
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Deletar gerações antigas (mantém as mais recentes no menu de boot)
sudo nix-collect-garbage -d

# Ou deletar gerações específicas
sudo nix-env --delete-generations 1 2 3 --profile /nix/var/nix/profiles/system
```

---

## 🔧 Personalizações Interessantes

### Home Manager

O Home Manager está separado em `home.nix` para gerenciar configurações em nível de usuário. Configurações do dconf/GNOME ficam lá.

### PostgreSQL em Modo DEV

O PostgreSQL está configurado com **autenticação trust** (sem senha). Perfeito para desenvolvimento local — **nunca use isso em produção ou em sistemas expostos**.

### Configuração Automática do Flatpak

Um serviço systemd adiciona automaticamente o repositório Flathub na primeira inicialização.

### Limite de Boot

O bootloader mantém apenas as últimas 3 gerações do sistema (configurável via `boot.loader.systemd-boot.configurationLimit` em `modules/boot.nix`).

### OBS Studio com CUDA

OBS configurado com suporte NVIDIA CUDA para melhor performance de encoding.

---

## 💡 Dicas

- **Suporte NTFS:** Habilitado para setups de dual-boot com Windows
- **Kernel:** Sempre o mais recente (mude para LTS em `modules/boot.nix` se preferir estabilidade)
- **NVIDIA:** Se suspend/hibernate apresentarem problemas, habilite `powerManagement.enable = true` em `modules/hardware.nix`
- **Wayland:** Funciona perfeitamente com GNOME e drivers NVIDIA recentes
- **Flakes:** Não esqueça de fazer `git add` em arquivos novos antes de testar!

---

## 🤝 Contribuindo

Encontrou algo interessante ou tem sugestões? Fique à vontade para abrir uma issue ou PR. Este é um projeto pessoal, mas adoro aprender com a comunidade.

---

## 📝 Notas

- Esta configuração é pessoal, mas pública para ajudar outros usuários do NixOS
- Baseada no NixOS 26.05 (pode requerer ajustes para outras versões)
- Testada apenas no meu hardware (mas deve funcionar em outros com mudanças mínimas)
- Estrutura modular facilita customização para diferentes setups

---

## 📜 Licença

[![CC0](https://licensebuttons.net/p/zero/1.0/88x31.png)](https://creativecommons.org/publicdomain/zero/1.0/)
Esta configuração é lançada sob CC0 (Domínio Público). Use-a livremente!

---

_Feito com ❤️ e muito café ☕ no NixOS_

**P.S.:** Se você está lendo isso pensando "uma GTX 1060 em 2026?", sim — ainda aguenta firme. Sem julgamentos. 😅  
**P.P.S.:** Configuração refatorada para estrutura modular em 11/02/2026 — agora muito mais organizada!

</details>

<details>
<summary>English Documentation</summary>

# 🚀 My NixOS Config

> _"Humanity questioned. The computer calculated. Millions of years passed. The answer echoed through the cosmos: '42'. Meanwhile, in the basement, a dev discovered that `nixos-rebuild switch` solves almost everything. Almost."_

Welcome to my NixOS configuration! This is my personal setup running GNOME and the latest kernel version, organized in a modular structure for easy maintenance.

---

## 📊 The Setup

### Hardware

- **CPU:** AMD Ryzen 5 5600X
- **GPU:** NVIDIA GeForce GTX 1060 3GB _(yes, it's still alive and fighting bravely in 2026)_
- **RAM:** 32GB (because closing Chrome tabs is not an option)
- **Storage:** 3TB total (1TB SSD + 2× 1TB HDD)
- **Motherboard:** ASRock B450M Steel Legend

### Software

- **OS:** NixOS 26.05 (Yarara)
- **Kernel:** Linux 6.18.4 (always latest)
- **DE:** GNOME 49 (Wayland)
- **DM:** SDDM with Wayland support
- **Shell:** Fish (life is too short for bash)

---

## ✨ Key Features

### 🎨 Visual

- **Gruvbox theme** everywhere (GTK3, GTK4, GNOME)
- **JetBrains Mono Nerd Font** — because developers need style
- GNOME extensions: Dash to Dock, User Themes, Blur My Shell
- SDDM with custom theme (where_is_my_sddm_theme)

### 🛠️ Development

- **PostgreSQL 15** configured in DEV mode (trust auth, no password — **DO NOT USE IN PRODUCTION**)
- Pre-created databases: `mydatabase` and `anorak`
- **direnv + nix-direnv** for isolated development environments
- **Node.js + Yarn** for web development
- **VS Code, Zed Editor, Helix, Neovim** — pick your weapon
- **LSPs:** nixd, clang-tools, lua-language-server, pyright
- **Rust, GCC, Make** ready to use

### 🎮 Gaming & Entertainment

- **Steam** with 32-bit support
- **Lutris** for multi-platform gaming
- **PCSX2** (PS2 emulator)
- **RPCS3** (PS3 emulator)
- **Wine (Wayland)** for Windows games
- **Bottles** to manage Wine prefixes

### 🎮 Apps & Productivity

- **Ghostty** (modern and fast terminal)
- **Cool Retro Term** (because sometimes we want to hack like it's the 80s)
- **Firefox** (pre-installed)
- **Flatpak** enabled with Flathub
- **Discord** for communication
- **Element** for Matrix
- **Spotify** for coding soundtracks
- **Obsidian** to organize mental chaos
- **Anytype** via AppImage
- **VLC** — it plays everything
- **Jellyfin** (media server + desktop client)

### 🐟 Fish Shell Setup

Configured plugins:

- `done` — notifications when long-running commands finish
- `fzf-fish` — fuzzy search everywhere
- `forgit` — interactive and clean Git workflow
- `hydro` — minimal and fast prompt
- `grc` — command output colorization

### 🎯 NVIDIA Drivers

- Proprietary drivers (stable)
- Modesetting enabled
- 32-bit support (for legacy games)
- CUDA enabled (for OBS Studio)

### 🖥️ Virtualization

- **libvirtd + QEMU/KVM** configured
- **virt-manager** for GUI management
- Virtual TPM (swtpm) enabled
- NAT network configured (192.168.122.0/24)

---

## 🔐 Secure Boot with Lanzaboote (Flakes)

**Full tutorial here** = [Setup Guide](./nixos_secureboot_tutorial.md)

This configuration uses **lanzaboote** to enable **UEFI Secure Boot** while keeping the system fully declarative and compatible with **Nix flakes**.

### Why Lanzaboote?

- Works seamlessly with **systemd-boot**
- Fully declarative Secure Boot setup
- Ideal for **flake-based** NixOS systems
- Automatically signs kernels and boot artifacts

### Key Characteristics

- Secure Boot **enabled and enforced**
- Custom Machine Owner Key (MOK) managed by NixOS
- Compatible with system rollbacks and generations
- No shim required

### High-Level Setup Overview

- Secure Boot keys are generated and managed declaratively
- systemd-boot is used as the bootloader
- lanzaboote signs EFI binaries automatically during rebuilds
- Flakes are used as the entry point for system configuration

### Notes

- After initial key enrollment, Secure Boot remains enabled across rebuilds
- If firmware settings are reset, keys may need to be re-enrolled
- This setup is ideal for laptops and desktops that require Secure Boot (e.g. dual-boot with Windows)

> ⚠️ Important: Once Secure Boot is enabled and enforced, unsigned kernels **will not boot**.

---

## 📁 Repository Structure

```
/etc/nixos/
├── flake.nix                   # Flake entry point
├── flake.lock                  # Flake lock file
├── configuration.nix           # Main config (imports only!)
├── hardware-configuration.nix  # Auto-generated hardware config
├── disks.nix                   # Disk layout configuration
├── home.nix                    # Home Manager user configuration
├── modules/
│   ├── boot.nix               # Bootloader, kernel, secure boot
│   ├── system.nix             # Hostname, locale, timezone, nix settings
│   ├── hardware.nix           # NVIDIA, graphics, sound
│   ├── desktop.nix            # GNOME, SDDM, Qt configuration
│   ├── services.nix           # PostgreSQL, Jellyfin, printing, flatpak
│   ├── virtualization.nix     # libvirt, QEMU, virt-manager
│   ├── programs.nix           # System programs (fish, direnv, obs, etc)
│   ├── users.nix              # User account configuration
│   └── packages.nix           # All system packages
└── README.md                   # You are here 👋
```

### 🎯 Modular Structure Advantages

✅ **Clear organization** — each file has a specific purpose  
✅ **Easy maintenance** — want to change GNOME settings? Go straight to `modules/desktop.nix`  
✅ **Reusable** — copy modules to other machines  
✅ **Version controlled** — clean git history  
✅ **Scalable** — easy to add new modules without mess

---

## 🚀 How to Use

### Fresh Installation

1. Clone this repository:

```bash
git clone https://github.com/SirSouza/nixos-config.git /etc/nixos
cd /etc/nixos
```

2. **IMPORTANT:** Create your `disks.nix` according to your system (or copy from the example)

3. Generate your hardware config:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

4. Edit relevant modules:

- `modules/users.nix` — replace `anorak` with your username
- `modules/system.nix` — adjust hostname, timezone, locale
- `modules/services.nix` — configure PostgreSQL databases (if needed)
- `modules/packages.nix` — add/remove packages as needed

5. Rebuild the system with flakes:

```bash
sudo nixos-rebuild switch --flake /etc/nixos
```

---

### Updating the System

```bash
# Update flake inputs
cd /etc/nixos
nix flake update

# Rebuild with updates
sudo nixos-rebuild switch --flake /etc/nixos

# Or from anywhere
sudo nixos-rebuild switch --flake /etc/nixos
```

---

### Cleaning Old Generations

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old generations (keeps latest ones in boot menu)
sudo nix-collect-garbage -d

# Or delete specific generations
sudo nix-env --delete-generations 1 2 3 --profile /nix/var/nix/profiles/system
```

---

## 🔧 Interesting Customizations

### Home Manager

Home Manager is separated into `home.nix` to manage user-level configuration. GNOME/dconf settings live there, but GTK themes are managed manually via GNOME Tweaks.

### PostgreSQL in DEV Mode

PostgreSQL is configured with **trust authentication** (no password). Perfect for local development — **never use this in production or on exposed systems**.

### Flatpak Auto Setup

A systemd service automatically adds the Flathub repository on first boot.

### Boot Limit

The bootloader keeps only the last 3 system generations (configurable via `boot.loader.systemd-boot.configurationLimit` in `modules/boot.nix`).

### OBS Studio with CUDA

OBS configured with NVIDIA CUDA support for better encoding performance.

---

## 💡 Tips

- **NTFS Support:** Enabled for Windows dual-boot setups
- **Kernel:** Always latest (switch to LTS in `modules/boot.nix` if you prefer stability)
- **NVIDIA:** If suspend/hibernate misbehaves, enable `powerManagement.enable = true` in `modules/hardware.nix`
- **Wayland:** Works flawlessly with GNOME and recent NVIDIA drivers
- **Flakes:** Don't forget to `git add` new files before testing!

---

## 🤝 Contributing

Found something interesting or have suggestions? Feel free to open an issue or PR. This is a personal project, but I love learning from the community.

---

## 📝 Notes

- This config is personal but public to help other NixOS users
- Based on NixOS 26.05 (may require adjustments for other versions)
- Tested only on my hardware (but should work elsewhere with minimal changes)
- Modular structure makes it easy to customize for different setups

---

## 📜 License

[![CC0](https://licensebuttons.net/p/zero/1.0/88x31.png)](https://creativecommons.org/publicdomain/zero/1.0/)
This configuration is released under CC0 (Public Domain). Use it freely!

---

_Made with ❤️ and lots of coffee ☕ on NixOS_

**P.S.:** If you're reading this thinking "a GTX 1060 in 2026?", yes — it's still holding up. Don't judge. 😅  
**P.P.S.:** Configuration refactored to modular structure on 02/11/2026 — much more organized now!

</details>
