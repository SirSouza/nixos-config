{ ... }:

{
  # Discos específicos desta máquina
  fileSystems."/mnt/Hard-Drive" = {
    device = "/dev/disk/by-uuid/8ABC98D3BC98BAE1";
    fsType = "ntfs";
    options = [ "rw" "uid=1000" "nofail" ];
  };

  fileSystems."/mnt/Hard-Drive-1" = {
    device = "/dev/disk/by-uuid/F2FEA9D5FEA99281";
    fsType = "ntfs";
    options = [ "rw" "uid=1000" "nofail" ];
  };
}
