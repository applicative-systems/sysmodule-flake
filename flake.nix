{
  description = "Importable flake.parts module for system modules";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, flake-parts-lib, ... }: {
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
    perSystem = { config, self', inputs', pkgs, system, ... }: { };
    flake = {
      flakeModules.default = flake-parts-lib.importApply ./flake-module.nix { inherit withSystem; };
      lib = import ./lib.nix inputs.nixpkgs.lib;
    };
  });
}
