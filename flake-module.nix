sysmodule-flake:

{ self, flake-parts-lib, lib, ... }: {
  imports = [
    ./modules/sys-discovery.nix
  ];

  config._module.args = { inherit sysmodule-flake; };

  _file = __curPos.file;
}
