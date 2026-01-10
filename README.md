# NixOS Configuration

Minha configuração pessoal do NixOS.

## 📋 Informações do Sistema

- **OS**: NixOS 25.11
- **Usuário**: anorak
- **Shell**: Fish (com plugins: done, fzf-fish, forgit, hydro, grc)
- **Desktop Environment**: GNOME com GDM
- **Display Manager**: GDM
- **GPU**: NVIDIA (driver proprietário estável)
- **Tema**: Gruvbox Dark (GTK + Ícones)
- **Kernel**: Linux Latest

## 🚀 Instalação

### Clonar o repositório

```bash
git clone git@github.com:SirSouza/nixos-config.git /tmp/nixos-config
```

### Aplicar a configuração

```bash
sudo cp -r /tmp/nixos-config/* /etc/nixos/
sudo nixos-rebuild switch
```

## 📁 Estrutura

```
/etc/nixos/
├── configuration.nix           # Configuração principal do sistema
├── hardware-configuration.nix  # Configuração de hardware (gerada automaticamente)
├── disks.nix                   # Configuração de discos (ver disks.nix.example)
└── README.md                   # Este arquivo
```

## 🔧 Principais Configurações

- **Bootloader**: systemd-boot (limite de 5 gerações, timeout 120s)
- **Network**: NetworkManager
- **Locale**: en_US.UTF-8 com formatos pt_BR
- **Timezone**: America/Sao_Paulo
- **Audio**: PipeWire (com suporte ALSA e PulseAudio)
- **Filesystems**: NTFS suportado
- **Home Manager**: Integrado

### Hardware

- **GPU**: NVIDIA (driver proprietário, modesetting habilitado)
- **OpenGL**: Habilitado com suporte 32-bit

### Desenvolvimento

- **PostgreSQL 15**: Configurado para desenvolvimento local (autenticação trust)
  - Databases: `mydatabase`, `anorak`
  - Usuário: `anorak` (com ownership)
- **Direnv**: Habilitado com nix-direnv
- **Node.js**: Instalado

### Tematização (Gruvbox)

- **GTK Theme**: Gruvbox-Dark-macos
- **Icon Theme**: Gruvbox-Plus-Dark
- **Font**: JetBrainsMono Nerd Font 11
- **Color Scheme**: Dark mode
- **GNOME Extensions**:
  - User Themes
  - Blur My Shell
  - Dash to Dock

### Pacotes Instalados

#### Desenvolvimento
- git, vim, vscode, nixfmt
- postgresql, nodejs
- direnv, fish (com plugins)

#### Comunicação
- vesktop, discord, element

#### Utilitários
- gnome-tweaks, gnome-extension-manager
- flatpak (com Flathub)
- grc, wget, ntfs3g

#### Multimídia & Produtividade
- firefox, spotify, vlc
- obsidian
- ghostty (terminal)

## 📝 Gerenciamento

### Atualizar o sistema

```bash
sudo nixos-rebuild switch --upgrade
```

### Fazer backup da configuração

```bash
cd /etc/nixos
sudo git add .
sudo git commit -m "Descrição das mudanças"
sudo git push
```

### Reverter para uma geração anterior

```bash
sudo nixos-rebuild switch --rollback
```

## 🔗 Links Úteis

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Options Search](https://search.nixos.org/options)
- [NixOS Packages Search](https://search.nixos.org/packages)
- [Nix Pills](https://nixos.org/guides/nix-pills/)

## 📄 Licença

MIT

## ✨ Créditos

Configuração criada e mantida por [@SirSouza](https://github.com/SirSouza)
