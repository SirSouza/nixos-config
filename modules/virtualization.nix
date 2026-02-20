{ config, pkgs, lib, ... }:

{
  # VM configuration
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
    onBoot = "start";
    onShutdown = "shutdown";
  };

  programs.virt-manager.enable = true;

  # Network configuration for VMs
  environment.etc."libvirt/qemu/networks/default.xml".text = ''
    <network>
      <name>default</name>
      <forward mode='nat'/>
      <bridge name='virbr0' stp='on' delay='0'/>
      <ip address='192.168.122.1' netmask='255.255.255.0'>
        <dhcp>
          <range start='192.168.122.2' end='192.168.122.254'/>
        </dhcp>
      </ip>
    </network>
  '';
}
