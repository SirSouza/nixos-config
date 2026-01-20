<details>
<summary>Documentação em Português BR</summary>

# 🚀 Minha Configuração NixOS

> _"A humanidade questionou. O computador calculou. Milhões de anos se passaram. A resposta ecoou pelo cosmos: '42'. Enquanto isso, no porão, um dev descobriu que `nixos-rebuild switch` resolve quase tudo. Quase."_

Bem-vindo à minha configuração do NixOS! Este é meu setup pessoal rodando GNOME e a versão mais recente do kernel.

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
- Extensões do GNOME: Dash to Dock, User Themes
- SDDM com tema Breeze (pode ser alterado depois)

### 🛠️ Desenvolvimento

- **PostgreSQL 15** configurado em modo DEV (autenticação trust, sem senha — **NÃO USE EM PRODUÇÃO**)
- Bancos de dados pré-criados: `mydatabase` e `anorak`
- **direnv + nix-direnv** para ambientes de desenvolvimento isolados
- **Node.js** (gostemos ou não, JavaScript domina o mundo)
- **VS Code** como IDE principal

### 🎮 Apps & Produtividade

- **Ghostty** (terminal moderno e rápido)
- **Firefox** (pré-instalado)
- **Flatpak** habilitado com Flathub
- **Discord** para comunicação
- **Spotify** para trilhas sonoras de programação
- **Obsidian** para organizar o caos mental
- **VLC** — reproduz tudo

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
.
├── configuration.nix           # Configuração principal do sistema
├── hardware-configuration.nix  # Configuração de hardware auto-gerada
├── disks.nix                   # Layout dos discos (criar baseado no exemplo)
└── README.md                   # Você está aqui 👋
```

---

## 🚀 Como Usar

### Instalação do Zero

1. Clone este repositório:

```bash
git clone https://github.com/SirSouza/nixos-config.git /etc/nixos
cd /etc/nixos
```

2. **IMPORTANTE:** Crie seu `disks.nix` de acordo com seu sistema (ou copie do exemplo)

3. Gere sua configuração de hardware:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

4. Edite `configuration.nix` e ajuste:

- Nome de usuário (substitua `anorak` pelo seu)
- Hostname
- Bancos de dados PostgreSQL (se necessário)

5. Recompile o sistema:

```bash
sudo nixos-rebuild switch
```

6. Com flakes:

- Recomendo fortemente usar aliases para isso.

```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .#você
```

- De qualquer lugar no seu NixOS

```bash
sudo nixos-rebuild switch --flake /etc/nixos
```

---

### Atualizando o Sistema

```bash
# Atualizar canais
sudo nix-channel --update

# Recompilar
sudo nixos-rebuild switch
ou
sudo nixos-rebuild switch --flake /etc/nixos # para flakes
# Ou tudo de uma vez
sudo nix-channel --update && sudo nixos-rebuild switch
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

O Home Manager está integrado ao NixOS para gerenciar configurações em nível de usuário. Toda a tematização Gruvbox, fontes e configurações do GNOME ficam em `home-manager.users.anorak`.

### PostgreSQL em Modo DEV

O PostgreSQL está configurado com **autenticação trust** (sem senha). Perfeito para desenvolvimento local — **nunca use isso em produção ou em sistemas expostos**.

### Configuração Automática do Flatpak

Um serviço systemd adiciona automaticamente o repositório Flathub na primeira inicialização.

### Limite de Boot

O bootloader mantém apenas as últimas 4 gerações do sistema (configurável via `boot.loader.systemd-boot.configurationLimit`).

---

## 💡 Dicas

- **Suporte NTFS:** Habilitado para setups de dual-boot com Windows
- **Kernel:** Sempre o mais recente (mude para LTS se preferir estabilidade)
- **NVIDIA:** Se suspend/hibernate apresentarem problemas, habilite `powerManagement.enable = true`
- **Wayland:** Funciona perfeitamente com GNOME e drivers NVIDIA recentes

---

## 🤝 Contribuindo

Encontrou algo interessante ou tem sugestões? Fique à vontade para abrir uma issue ou PR. Este é um projeto pessoal, mas adoro aprender com a comunidade.

---

## 📝 Notas

- Esta configuração é pessoal, mas pública para ajudar outros usuários do NixOS
- Baseada no NixOS 26.05 (pode requerer ajustes para outras versões)
- Testada apenas no meu hardware (mas deve funcionar em outros com mudanças mínimas)

---

## 📜 Licença

[![CC0](https://licensebuttons.net/p/zero/1.0/88x31.png)](https://creativecommons.org/publicdomain/zero/1.0/)
Esta configuração é lançada sob CC0 (Domínio Público). Use-a livremente!

---

_Feito com ❤️ e muito café ☕ no NixOS_

**P.S.:** Se você está lendo isso pensando "uma GTX 1060 em 2026?", sim — ainda aguenta firme. Sem julgamentos. 😅
**P.S. pt2:** Estou atualizando continuamente esta documentação e a configuração conforme aprendo sobre NixOS.

## </details>

<details>
<summary>
English Documentation
</summary>
# 🚀 My NixOS Config

> _"Humanity questioned. The computer calculated. Millions of years passed. The answer echoed through the cosmos: '42'. Meanwhile, in the basement, a dev discovered that `nixos-rebuild switch` solves almost everything. Almost."_

Welcome to my NixOS configuration! This is my personal setup running GNOME and the latest kernel version.

---

## 📊 The Setup

### Hardware

- **CPU:** AMD Ryzen 5 5600X
- **GPU:** NVIDIA GeForce GTX 1060 3GB _(yes, it’s still alive and fighting bravely in 2026)_
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
- GNOME extensions: Dash to Dock, User Themes
- SDDM with Breeze theme (can be changed later)

### 🛠️ Development

- **PostgreSQL 15** configured in DEV mode (trust auth, no password — **DO NOT USE IN PRODUCTION**)
- Pre-created databases: `mydatabase` and `anorak`
- **direnv + nix-direnv** for isolated development environments
- **Node.js** (whether we like it or not, JavaScript runs the world)
- **VS Code** as the main IDE

### 🎮 Apps & Productivity

- **Ghostty** (modern and fast terminal)
- **Firefox** (pre-installed)
- **Flatpak** enabled with Flathub
- **Discord** for communication
- **Spotify** for coding soundtracks
- **Obsidian** to organize mental chaos
- **VLC** — it plays everything

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
.
├── configuration.nix           # Main system configuration
├── hardware-configuration.nix  # Auto-generated hardware config
├── disks.nix                   # Disk layout (create based on the example)
└── README.md                   # You are here 👋
```

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

4. Edit `configuration.nix` and adjust:

- Username (replace `anorak` with yours)
- Hostname
- PostgreSQL databases (if needed)

5. Rebuild the system:

```bash
sudo nixos-rebuild switch
```

6. With flakes:

- I strongly recommend using aliases for this.

```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .#you
```

- From anywhere in your NixOS

```bash
sudo nixos-rebuild switch --flake /etc/nixos
```

---

### Updating the System

```bash
# Update channels
sudo nix-channel --update

# Rebuild
sudo nixos-rebuild switch
or
sudo nixos-rebuild switch --flake /etc/nixos # for flakes
# Or everything at once
sudo nix-channel --update && sudo nixos-rebuild switch
```

---

### Cleaning Old Generations

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old generations (keeps the latest ones in the boot menu)
sudo nix-collect-garbage -d

# Or delete specific generations
sudo nix-env --delete-generations 1 2 3 --profile /nix/var/nix/profiles/system
```

---

## 🔧 Interesting Customizations

### Home Manager

Home Manager is integrated into NixOS to manage user-level configuration. All Gruvbox theming, fonts, and GNOME settings live under `home-manager.users.anorak`.

### PostgreSQL in DEV Mode

PostgreSQL is configured with **trust authentication** (no password). Perfect for local development — **never use this in production or on exposed systems**.

### Flatpak Auto Setup

A systemd service automatically adds the Flathub repository on first boot.

### Boot Limit

The bootloader keeps only the last 4 system generations (configurable via `boot.loader.systemd-boot.configurationLimit`).

---

## 💡 Tips

- **NTFS Support:** Enabled for Windows dual-boot setups
- **Kernel:** Always latest (switch to LTS if you prefer stability)
- **NVIDIA:** If suspend/hibernate misbehaves, enable `powerManagement.enable = true`
- **Wayland:** Works flawlessly with GNOME and recent NVIDIA drivers

---

## 🤝 Contributing

Found something interesting or have suggestions? Feel free to open an issue or PR. This is a personal project, but I love learning from the community.

---

## 📝 Notes

- This config is personal but public to help other NixOS users
- Based on NixOS 26.05 (may require adjustments for other versions)
- Tested only on my hardware (but should work elsewhere with minimal changes)

---

## 📜 License

[![CC0](https://licensebuttons.net/p/zero/1.0/88x31.png)](https://creativecommons.org/publicdomain/zero/1.0/)
This configuration is released under CC0 (Public Domain). Use it freely!

---

_Made with ❤️ and lots of coffee ☕ on NixOS_

**P.S.:** If you’re reading this thinking “a GTX 1060 in 2026?”, yes — it’s still holding up. Don’t judge. 😅
**P.S. pt2:** I'm continuously updating this documentation and the configuration as i learn about NixOS.

</details>
