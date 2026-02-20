{ ... }:

{
  fileSystems."/mnt/C3PO" = {
    device = "/dev/disk/by-uuid/8ABC98D3BC98BAE1";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "nofail"
      "noatime"
    ];
  };

  fileSystems."/mnt/R2D2" = {
    device = "/dev/disk/by-uuid/e02f155d-fb48-4b8c-af8c-38f36f026165";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "nofail"
    ];
  };
}
