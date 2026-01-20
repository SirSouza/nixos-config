## Guia Secure Boot

<details>
<summary>Português BR</summary>
# Configuração do Secure Boot no NixOS com Lanzaboote

Um guia completo, passo a passo, para configurar o UEFI Secure Boot no NixOS usando Lanzaboote, com suporte para dual boot com Windows.

## Índice

- [Pré-requisitos](#pré-requisitos)
- [O que é Secure Boot?](#o-que-é-secure-boot)
- [O que é Lanzaboote?](#o-que-é-lanzaboote)
- [Antes de Começar](#antes-de-começar)
- [Passo 1: Verificar Requisitos do Sistema](#passo-1-verificar-requisitos-do-sistema)
- [Passo 2: Habilitar Flakes](#passo-2-habilitar-flakes)
- [Passo 3: Configurar Lanzaboote](#passo-3-configurar-lanzaboote)
- [Passo 4: Gerar Chaves do Secure Boot](#passo-4-gerar-chaves-do-secure-boot)
- [Passo 5: Compilar e Verificar](#passo-5-compilar-e-verificar)
- [Passo 6: Registrar Chaves](#passo-6-registrar-chaves)
- [Passo 7: Habilitar Secure Boot](#passo-7-habilitar-secure-boot)
- [Solução de Problemas](#solução-de-problemas)
- [Dual Boot com Windows](#dual-boot-com-windows)
- [Manutenção](#manutenção)

---

## Pré-requisitos

- NixOS instalado em modo UEFI
- systemd-boot como bootloader
- Conhecimento básico de configuração do NixOS
- Acesso às configurações da BIOS/UEFI
- **IMPORTANTE:** Backup dos seus dados importantes

---

## O que é Secure Boot?

O UEFI Secure Boot é um recurso de segurança que garante que apenas sistemas operacionais confiáveis possam inicializar no seu sistema. Funciona através de:

1. **Assinaturas digitais**: Todos os componentes de boot (bootloader, kernel, initrd) são assinados criptograficamente
2. **Cadeia de confiança**: Cada componente verifica o próximo antes de carregá-lo
3. **Validação de chaves**: O firmware UEFI verifica as assinaturas contra chaves registradas

**Por que usar Secure Boot?**

- Proteção contra malware no nível de boot
- Defesa contra ataques de evil maid
- Requerido por alguns softwares (ex: Windows 11, alguns sistemas anti-cheat)

---

## O que é Lanzaboote?

[Lanzaboote](https://github.com/nix-community/lanzaboote) é uma implementação de Secure Boot projetada especificamente para NixOS.

**Recursos principais:**

- Assinatura automática de arquivos de boot a cada rebuild
- Gerenciamento eficiente de UKI (Unified Kernel Image)
- Mantém kernel e initrd separados (economiza espaço na ESP)
- Integra-se perfeitamente com as gerações do NixOS

**Vantagens sobre systemd-stub:**

- Arquivos UKI menores (kernel e initrd armazenados separadamente)
- Melhor para sistemas com muitas gerações (espaço ESP limitado)
- Otimizações específicas para NixOS

---

## Antes de Começar

### ⚠️ Avisos Importantes

1. **Faça backup das suas chaves do Secure Boot** - Se você perdê-las e algo quebrar, precisará desabilitar o Secure Boot para inicializar
2. **Configure uma senha na BIOS** - Sem ela, o Secure Boot pode ser facilmente desabilitado por um invasor
3. **Ainda está em desenvolvimento** - O Lanzaboote funciona bem, mas ainda não foi integrado ao nixpkgs
4. **Teste primeiro com Secure Boot desabilitado** - Só habilite depois que tudo estiver funcionando

### O que Você Vai Precisar

- Pelo menos **100GB** de espaço livre (compilações do NixOS podem ser grandes)
- Conexão com a internet (para baixar pacotes)
- 30-60 minutos de tempo
- Um pendrive ou armazenamento em nuvem para backup das chaves

---

## Passo 1: Verificar Requisitos do Sistema

Verifique se o seu sistema atende aos requisitos:

```bash
bootctl status
```

**Saída esperada:**

```
System:
     Firmware: UEFI 2.XX  # Deve ser UEFI, não BIOS
  Secure Boot: disabled    # Vamos habilitar isso depois
 TPM2 Support: yes         # Recomendado mas não obrigatório

Current Boot Loader:
      Product: systemd-boot  # Deve ser systemd-boot
```

Se você ver:

- ❌ `Firmware: BIOS` → Você precisa reinstalar em modo UEFI
- ❌ `Product: GRUB` → Mude para systemd-boot primeiro
- ✅ `Firmware: UEFI` + `Product: systemd-boot` → Você está pronto!

---

## Passo 2: Habilitar Flakes

O Lanzaboote requer Nix flakes. Adicione isso ao seu `configuration.nix`:

```nix
{ config, pkgs, lib, ... }:

{
  # ... sua configuração existente ...

  # Habilitar flakes e nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ... resto da sua configuração ...
}
```

Aplique as mudanças:

```bash
sudo nixos-rebuild switch
```

---

## Passo 3: Configurar Lanzaboote

### Criar `flake.nix`

Crie `/etc/nixos/flake.nix`:

```nix
{
  description = "Configuração do NixOS com Secure Boot";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, ... }: {
    nixosConfigurations.SEU-HOSTNAME = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager  # Se você usa home-manager
        lanzaboote.nixosModules.lanzaboote
      ];
    };
  };
}
```

**Substitua `SEU-HOSTNAME`** pelo seu hostname real (verifique com `hostname`).

### Atualizar `configuration.nix`

Modifique a configuração do seu bootloader:

```nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Remova: <home-manager/nixos>  # Agora vem do flake
  ];

  # Desabilitar systemd-boot (Lanzaboote o substitui)
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Configurar Lanzaboote
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Opcional: Limitar entradas de boot para economizar espaço
  boot.loader.systemd-boot.configurationLimit = 5;

  # Instalar sbctl para gerenciamento de chaves
  environment.systemPackages = with pkgs; [
    sbctl
    # ... seus outros pacotes ...
  ];

  # ... resto da sua configuração ...
}
```

### Rastrear arquivos com Git

Flakes só veem arquivos rastreados pelo git:

```bash
cd /etc/nixos
sudo git init  # Se ainda não for um repositório git
sudo git add .
sudo git commit -m "Commit inicial com Lanzaboote"
```

---

## Passo 4: Gerar Chaves do Secure Boot

Compile o sistema primeiro (Secure Boot ainda desabilitado):

```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .
```

Isso levará um tempo na primeira execução (baixando e compilando).

### Gerar chaves com sbctl

```bash
sudo sbctl create-keys
```

**Saída:**

```
Created Owner UUID xxxxx
Creating secure boot keys...✓
Secure boot keys created!
```

As chaves são armazenadas em `/var/lib/sbctl/keys/`.

### Fazer backup das suas chaves (CRÍTICO!)

```bash
# Criar backup
sudo tar -czf ~/secureboot-keys-backup.tar.gz /var/lib/sbctl/

# Copiar para local seguro
# - Pendrive
# - Armazenamento em nuvem
# - Outro computador
```

**⚠️ NÃO PERCA ESTE BACKUP!** Se você perder as chaves e algo quebrar, precisará desabilitar o Secure Boot para recuperar.

---

## Passo 5: Compilar e Verificar

Recompile o sistema com Lanzaboote:

```bash
sudo nixos-rebuild switch --flake .
```

**Saída esperada:**

```
Installing Lanzaboote to "/boot"...
Updating "/boot/EFI/BOOT/BOOTX64.EFI"...
Successfully installed Lanzaboote.
```

### Verificar assinaturas

Verifique se os arquivos de boot estão assinados:

```bash
sudo sbctl verify
```

**Você deve ver:**

```
✓ /boot/EFI/BOOT/BOOTX64.EFI is signed
✓ /boot/EFI/Linux/nixos-generation-X.efi is signed
✓ /boot/EFI/systemd/systemd-bootx64.efi is signed
```

**É normal ver:**

```
✗ /boot/EFI/Microsoft/Boot/bootmgfw.efi is not signed
```

Estes arquivos do Windows são assinados com as chaves da Microsoft, não as suas.

---

## Passo 6: Registrar Chaves

### Colocar UEFI em Setup Mode

1. Reinicie para as configurações da BIOS/UEFI:

   ```bash
   sudo systemctl reboot --firmware-setup
   ```

2. Navegue para **Security → Secure Boot**

3. Procure por opções como:
   - "Clear Secure Boot Keys"
   - "Reset to Setup Mode"
   - "Delete All Keys"
   - "Clear Platform Key (PK)"

4. Execute a opção de limpar chaves

5. **Salve e saia** - O sistema reiniciará

### Registrar suas chaves

Inicie de volta no NixOS e execute:

```bash
sudo sbctl enroll-keys --microsoft
```

**A flag `--microsoft`:**

- Mantém as chaves da Microsoft junto com as suas
- **Obrigatório para dual boot com Windows**
- Inofensivo se você não usa Windows

**Saída:**

```
Enrolling keys to EFI variables...
With vendor keys from microsoft...✓
Enrolled keys to the EFI variables!
```

### Verificar registro

```bash
bootctl status
```

Deve mostrar:

```
Secure Boot: disabled (setup)
```

O `(setup)` significa que as chaves estão registradas mas o Secure Boot ainda não está habilitado.

---

## Passo 7: Habilitar Secure Boot

### Habilitar na BIOS

1. Reinicie para a BIOS:

   ```bash
   sudo systemctl reboot --firmware-setup
   ```

2. Navegue para **Security → Secure Boot**

3. **Habilite Secure Boot**

4. **Salve e saia**

### Verificar se funcionou

Depois de inicializar no NixOS:

```bash
bootctl status
```

**Sucesso se parecer com:**

```
Secure Boot: enabled (user)
```

O `(user)` indica chaves personalizadas (não chaves de fábrica).

---

## Solução de Problemas

### Compilação falha com "No space left on device"

**Problema:** Espaço em disco insuficiente para compilações.

**Solução:**

```bash
# Limpar gerações antigas
sudo nix-collect-garbage -d

# Otimizar store
sudo nix-store --optimise

# Verificar espaço
df -h /
```

Recomendação: Tenha pelo menos 100GB para a partição do NixOS.

### "Cannot build cargo" ou erros de compilação Rust

**Problema:** Incompatibilidade de versão com Lanzaboote v0.4.1.

**Solução:** Use a versão mais recente removendo a tag de versão em `flake.nix`:

```nix
lanzaboote = {
  url = "github:nix-community/lanzaboote";  # Remova /v0.4.1
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Então:

```bash
sudo rm flake.lock
sudo nixos-rebuild switch --flake .
```

### "Your system is not in Setup Mode"

**Problema:** Tentou registrar chaves sem limpar as chaves existentes.

**Solução:**

1. Reinicie para a BIOS
2. Limpe as chaves do Secure Boot (veja Passo 6)
3. Inicie no NixOS
4. Tente `sudo sbctl enroll-keys --microsoft` novamente

### Sistema não inicia após habilitar Secure Boot

**Correção imediata:**

1. Entre na BIOS
2. **Desabilite Secure Boot**
3. Inicie no NixOS

**Então faça debug:**

```bash
# Verificar o que não está assinado
sudo sbctl verify

# Verificar logs
journalctl -b

# Recompilar
sudo nixos-rebuild switch --flake .
```

### Avisos "Git tree is dirty"

**Não é crítico** - Apenas significa que há mudanças não commitadas.

**Para corrigir:**

```bash
cd /etc/nixos
sudo git add .
sudo git commit -m "Atualizar configuração"
```

---

## Dual Boot com Windows

### Entrada do Windows Não Aparece

Se o Windows não aparecer no menu do systemd-boot:

```bash
# Verificar se o bootloader do Windows existe
ls /boot/EFI/Microsoft/Boot/bootmgfw.efi

# Se existir, criar entrada manual
sudo tee /boot/loader/entries/windows.conf << 'EOF'
title Windows
efi /EFI/Microsoft/Boot/bootmgfw.efi
EOF
```

### Testando Windows com Secure Boot

1. Reinicie e selecione Windows no menu do systemd-boot
2. Windows deve inicializar normalmente

**Se o Windows não inicializar:**

- Certifique-se de ter usado a flag `--microsoft` ao registrar as chaves
- Verifique se o Secure Boot está habilitado na BIOS

### Acessando Menu de Boot

**Durante o boot:**

- Seleção NixOS/Windows: menu do systemd-boot (automático)
- Menu de boot da BIOS: Geralmente **F11**, **F12**, ou **ESC** (consulte o manual da sua placa-mãe)

---

## Manutenção

### Após Atualizações do Sistema

O Lanzaboote **assina automaticamente novos kernels** a cada rebuild. Apenas:

```bash
sudo nixos-rebuild switch --flake .
```

Não é necessária assinatura manual!

### Limpando Gerações Antigas

Sua configuração limita a 5 gerações, mas limpe manualmente com:

```bash
# Listar gerações
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Deletar antigas
sudo nix-collect-garbage -d

# Recompilar para atualizar menu de boot
sudo nixos-rebuild switch --flake .
```

### Atualizando Inputs do Flake

Atualizar nixpkgs, lanzaboote, etc:

```bash
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild switch --flake .
```

### Coleta Automática de Lixo

Adicione ao `configuration.nix` para limpeza automática:

```nix
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 7d";
};
```

### Verificação de Backup de Chaves

Verifique periodicamente se seu backup existe e está acessível:

```bash
# Verificar se o backup existe
ls -lh ~/secureboot-keys-backup.tar.gz

# Verificar conteúdo
tar -tzf ~/secureboot-keys-backup.tar.gz
```

---

## FAQ

### Preciso re-assinar arquivos manualmente?

**Não!** O Lanzaboote assina tudo automaticamente durante o `nixos-rebuild`.

### Posso usar isso com GRUB?

**Não.** O Lanzaboote requer systemd-boot. Se você precisa de GRUB, procure outras soluções de Secure Boot.

### Isso funcionará com outras distros em multi-boot?

**NixOS:** Sim, totalmente suportado  
**Windows:** Sim, com a flag `--microsoft`  
**Outras distros Linux:** Elas precisam de sua própria configuração de Secure Boot

### E se eu precisar desabilitar o Secure Boot temporariamente?

Apenas desabilite na BIOS. Suas chaves permanecem registradas. Re-habilite a qualquer momento.

### Como sei se o Secure Boot está realmente funcionando?

```bash
bootctl status | grep "Secure Boot"
```

Deve mostrar: `Secure Boot: enabled (user)`

### Posso usar isso em um laptop com chaves Secure Boot existentes?

Sim, mas você precisa limpar as chaves de fábrica primeiro (Setup Mode). Seu backup é crucial aqui.

---

## Recursos Adicionais

- [Lanzaboote GitHub](https://github.com/nix-community/lanzaboote)
- [Documentação do Lanzaboote](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md)
- [NixOS Wiki - Secure Boot](https://nixos.wiki/wiki/Secure_Boot)
- [sbctl GitHub](https://github.com/Foxboron/sbctl)

---

## Créditos

Este guia foi criado com base em experiência de configuração real e documentação da comunidade.

**Contribuindo:** Encontrou um erro ou tem melhorias? Abra uma issue ou PR!

---

## Licença

Este guia é lançado sob CC0 (Domínio Público). Use-o livremente!

---

**Feliz Secure Booting!** 🔒🚀

 </details>

# Secure Boot Setup Guide

<details>
<summary>English</summary>
# NixOS Secure Boot Setup with Lanzaboote

A complete, step-by-step guide to configure UEFI Secure Boot on NixOS using Lanzaboote, with dual-boot Windows support.

## Table of Contents

- [Prerequisites](#prerequisites)
- [What is Secure Boot?](#what-is-secure-boot)
- [What is Lanzaboote?](#what-is-lanzaboote)
- [Before You Start](#before-you-start)
- [Step 1: Verify System Requirements](#step-1-verify-system-requirements)
- [Step 2: Enable Flakes](#step-2-enable-flakes)
- [Step 3: Configure Lanzaboote](#step-3-configure-lanzaboote)
- [Step 4: Generate Secure Boot Keys](#step-4-generate-secure-boot-keys)
- [Step 5: Build and Verify](#step-5-build-and-verify)
- [Step 6: Enroll Keys](#step-6-enroll-keys)
- [Step 7: Enable Secure Boot](#step-7-enable-secure-boot)
- [Troubleshooting](#troubleshooting)
- [Dual Boot with Windows](#dual-boot-with-windows)
- [Maintenance](#maintenance)

---

## Prerequisites

- NixOS installed in UEFI mode
- systemd-boot as bootloader
- Basic understanding of NixOS configuration
- Access to BIOS/UEFI settings
- **IMPORTANT:** Backup of your important data

---

## What is Secure Boot?

UEFI Secure Boot is a security feature that ensures only trusted operating systems can boot on your system. It works by:

1. **Digital signatures**: All boot components (bootloader, kernel, initrd) are cryptographically signed
2. **Chain of trust**: Each component verifies the next before loading it
3. **Key validation**: The UEFI firmware checks signatures against enrolled keys

**Why use Secure Boot?**

- Protection against boot-level malware
- Defense against evil maid attacks
- Required by some software (e.g., Windows 11, some anti-cheat systems)

---

## What is Lanzaboote?

[Lanzaboote](https://github.com/nix-community/lanzaboote) is a Secure Boot implementation specifically designed for NixOS.

**Key features:**

- Automatic signing of boot files on each rebuild
- Efficient UKI (Unified Kernel Image) handling
- Keeps kernel and initrd separate (saves ESP space)
- Integrates seamlessly with NixOS generations

**Advantages over systemd-stub:**

- Smaller UKI files (kernel and initrd stored separately)
- Better for systems with many generations (limited ESP space)
- NixOS-specific optimizations

---

## Before You Start

### ⚠️ Important Warnings

1. **Backup your Secure Boot keys** - If you lose them and something breaks, you'll need to disable Secure Boot to boot
2. **Set a BIOS password** - Without it, Secure Boot can be easily disabled by an attacker
3. **This is still in development** - Lanzaboote works well but isn't upstreamed to nixpkgs yet
4. **Test with Secure Boot disabled first** - Only enable after everything is working

### What You'll Need

- At least **100GB** of free space (NixOS builds can be large)
- Internet connection (for downloading packages)
- 30-60 minutes of time
- A USB drive or cloud storage for key backup

---

## Step 1: Verify System Requirements

Check that your system meets the requirements:

```bash
bootctl status
```

**Required output:**

```
System:
     Firmware: UEFI 2.XX  # Must be UEFI, not BIOS
  Secure Boot: disabled    # We'll enable this later
 TPM2 Support: yes         # Recommended but not required

Current Boot Loader:
      Product: systemd-boot  # Must be systemd-boot
```

If you see:

- ❌ `Firmware: BIOS` → You need to reinstall in UEFI mode
- ❌ `Product: GRUB` → Switch to systemd-boot first
- ✅ `Firmware: UEFI` + `Product: systemd-boot` → You're ready!

---

## Step 2: Enable Flakes

Lanzaboote requires Nix flakes. Add this to your `configuration.nix`:

```nix
{ config, pkgs, lib, ... }:

{
  # ... your existing configuration ...

  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ... rest of your configuration ...
}
```

Apply the changes:

```bash
sudo nixos-rebuild switch
```

---

## Step 3: Configure Lanzaboote

### Create `flake.nix`

Create `/etc/nixos/flake.nix`:

```nix
{
  description = "NixOS Configuration with Secure Boot";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, ... }: {
    nixosConfigurations.YOUR-HOSTNAME = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager  # If you use home-manager
        lanzaboote.nixosModules.lanzaboote
      ];
    };
  };
}
```

**Replace `YOUR-HOSTNAME`** with your actual hostname (check with `hostname`).

### Update `configuration.nix`

Modify your bootloader configuration:

```nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Remove: <home-manager/nixos>  # Now comes from flake
  ];

  # Disable systemd-boot (Lanzaboote replaces it)
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Configure Lanzaboote
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Optional: Limit boot entries to save space
  boot.loader.systemd-boot.configurationLimit = 5;

  # Install sbctl for key management
  environment.systemPackages = with pkgs; [
    sbctl
    # ... your other packages ...
  ];

  # ... rest of your configuration ...
}
```

### Track files with Git

Flakes only see files tracked by git:

```bash
cd /etc/nixos
sudo git init  # If not already a git repo
sudo git add .
sudo git commit -m "Initial commit with Lanzaboote"
```

---

## Step 4: Generate Secure Boot Keys

Build the system first (Secure Boot still disabled):

```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .
```

This will take a while on the first run (downloading and compiling).

### Generate keys with sbctl

```bash
sudo sbctl create-keys
```

**Output:**

```
Created Owner UUID xxxxx
Creating secure boot keys...✓
Secure boot keys created!
```

Keys are stored in `/var/lib/sbctl/keys/`.

### Backup your keys (CRITICAL!)

```bash
# Create backup
sudo tar -czf ~/secureboot-keys-backup.tar.gz /var/lib/sbctl/

# Copy to safe location
# - USB drive
# - Cloud storage
# - Another computer
```

**⚠️ DO NOT LOSE THIS BACKUP!** If you lose keys and something breaks, you'll need to disable Secure Boot to recover.

---

## Step 5: Build and Verify

Rebuild the system with Lanzaboote:

```bash
sudo nixos-rebuild switch --flake .
```

**Expected output:**

```
Installing Lanzaboote to "/boot"...
Updating "/boot/EFI/BOOT/BOOTX64.EFI"...
Successfully installed Lanzaboote.
```

### Verify signatures

Check that boot files are signed:

```bash
sudo sbctl verify
```

**You should see:**

```
✓ /boot/EFI/BOOT/BOOTX64.EFI is signed
✓ /boot/EFI/Linux/nixos-generation-X.efi is signed
✓ /boot/EFI/systemd/systemd-bootx64.efi is signed
```

**It's normal to see:**

```
✗ /boot/EFI/Microsoft/Boot/bootmgfw.efi is not signed
```

These Windows files are signed with Microsoft's keys, not yours.

---

## Step 6: Enroll Keys

### Put UEFI in Setup Mode

1. Reboot into BIOS/UEFI settings:

   ```bash
   sudo systemctl reboot --firmware-setup
   ```

2. Navigate to **Security → Secure Boot**

3. Look for options like:
   - "Clear Secure Boot Keys"
   - "Reset to Setup Mode"
   - "Delete All Keys"
   - "Clear Platform Key (PK)"

4. Execute the key clearing option

5. **Save and exit** - System will reboot

### Enroll your keys

Boot back into NixOS and run:

```bash
sudo sbctl enroll-keys --microsoft
```

**The `--microsoft` flag:**

- Keeps Microsoft's keys alongside yours
- **Required for Windows dual-boot**
- Harmless if you don't use Windows

**Output:**

```
Enrolling keys to EFI variables...
With vendor keys from microsoft...✓
Enrolled keys to the EFI variables!
```

### Verify enrollment

```bash
bootctl status
```

Should show:

```
Secure Boot: disabled (setup)
```

The `(setup)` means keys are enrolled but Secure Boot is not yet enabled.

---

## Step 7: Enable Secure Boot

### Enable in BIOS

1. Reboot into BIOS:

   ```bash
   sudo systemctl reboot --firmware-setup
   ```

2. Navigate to **Security → Secure Boot**

3. **Enable Secure Boot**

4. **Save and exit**

### Verify it worked

After booting into NixOS:

```bash
bootctl status
```

**Success looks like:**

```
Secure Boot: enabled (user)
```

The `(user)` indicates custom keys (not factory keys).

---

## Troubleshooting

### Build fails with "No space left on device"

**Problem:** Not enough disk space for builds.

**Solution:**

```bash
# Clean old generations
sudo nix-collect-garbage -d

# Optimize store
sudo nix-store --optimise

# Check space
df -h /
```

Recommendation: Have at least 100GB for NixOS partition.

### "Cannot build cargo" or Rust compilation errors

**Problem:** Version incompatibility with Lanzaboote v0.4.1.

**Solution:** Use the latest version by removing version tag in `flake.nix`:

```nix
lanzaboote = {
  url = "github:nix-community/lanzaboote";  # Remove /v0.4.1
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then:

```bash
sudo rm flake.lock
sudo nixos-rebuild switch --flake .
```

### "Your system is not in Setup Mode"

**Problem:** Tried to enroll keys without clearing existing keys.

**Solution:**

1. Reboot into BIOS
2. Clear Secure Boot keys (see Step 6)
3. Boot into NixOS
4. Try `sudo sbctl enroll-keys --microsoft` again

### System won't boot after enabling Secure Boot

**Immediate fix:**

1. Enter BIOS
2. **Disable Secure Boot**
3. Boot into NixOS

**Then debug:**

```bash
# Check what's not signed
sudo sbctl verify

# Check logs
journalctl -b

# Rebuild
sudo nixos-rebuild switch --flake .
```

### "Git tree is dirty" warnings

**Not critical** - Just means uncommitted changes.

**To fix:**

```bash
cd /etc/nixos
sudo git add .
sudo git commit -m "Update configuration"
```

---

## Dual Boot with Windows

### Windows Entry Not Showing

If Windows doesn't appear in systemd-boot menu:

```bash
# Check if Windows bootloader exists
ls /boot/EFI/Microsoft/Boot/bootmgfw.efi

# If it exists, create manual entry
sudo tee /boot/loader/entries/windows.conf << 'EOF'
title Windows
efi /EFI/Microsoft/Boot/bootmgfw.efi
EOF
```

### Testing Windows with Secure Boot

1. Reboot and select Windows in systemd-boot menu
2. Windows should boot normally

**If Windows doesn't boot:**

- Make sure you used `--microsoft` flag when enrolling keys
- Check that Secure Boot is enabled in BIOS

### Accessing Boot Menu

**During boot:**

- NixOS/Windows selection: systemd-boot menu (automatic)
- BIOS boot menu: Usually **F11**, **F12**, or **ESC** (check your motherboard manual)

---

## Maintenance

### After System Updates

Lanzaboote **automatically signs new kernels** on each rebuild. Just:

```bash
sudo nixos-rebuild switch --flake .
```

No manual signing needed!

### Cleaning Old Generations

Your configuration limits to 5 generations, but manually clean with:

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old ones
sudo nix-collect-garbage -d

# Rebuild to update boot menu
sudo nixos-rebuild switch --flake .
```

### Updating Flake Inputs

Update nixpkgs, lanzaboote, etc:

```bash
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild switch --flake .
```

### Automatic Garbage Collection

Add to `configuration.nix` for automatic cleanup:

```nix
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 7d";
};
```

### Key Backup Verification

Periodically verify your backup exists and is accessible:

```bash
# Check backup exists
ls -lh ~/secureboot-keys-backup.tar.gz

# Verify contents
tar -tzf ~/secureboot-keys-backup.tar.gz
```

---

## FAQ

### Do I need to re-sign files manually?

**No!** Lanzaboote automatically signs everything during `nixos-rebuild`.

### Can I use this with GRUB?

**No.** Lanzaboote requires systemd-boot. If you need GRUB, look into other Secure Boot solutions.

### Will this work with other distros in multi-boot?

**NixOS:** Yes, fully supported  
**Windows:** Yes, with `--microsoft` flag  
**Other Linux distros:** They need their own Secure Boot configuration

### What if I need to disable Secure Boot temporarily?

Just disable it in BIOS. Your keys remain enrolled. Re-enable anytime.

### How do I know if Secure Boot is actually working?

```bash
bootctl status | grep "Secure Boot"
```

Should show: `Secure Boot: enabled (user)`

### Can I use this on a laptop with existing Secure Boot keys?

Yes, but you need to clear the factory keys first (Setup Mode). Your backup is crucial here.

---

## Additional Resources

- [Lanzaboote GitHub](https://github.com/nix-community/lanzaboote)
- [Lanzaboote Documentation](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md)
- [NixOS Wiki - Secure Boot](https://nixos.wiki/wiki/Secure_Boot)
- [sbctl GitHub](https://github.com/Foxboron/sbctl)

---

## Credits

This guide was created based on real-world setup experience and community documentation.

**Contributing:** Found an error or have improvements? Open an issue or PR!

---

## License

This guide is released under CC0 (Public Domain). Use it freely!

---

**Happy Secure Booting!** 🔒🚀

</details>
