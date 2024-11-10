{ config, lib, self, sysmodule-flake, ... }:

let
  localLib = import ../lib.nix lib;
  cfg = config.sysmodules-flake;

  modulesDirs = {
    darwinModules = "modules-darwin";
    homeManagerModules = "modules-home-manager";
    nixosModules = "modules-nixos";
  };

  configsDirs = {
    darwinConfigurations = {
      folder = "configs-darwin";
      function = specialArgs: configPath: cfg.nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        modules = [ configPath ];
      };
    };
    nixosConfigurations = {
      folder = "configs-nixos";
      function = specialArgs: configPath: lib.nixosSystem {
        inherit specialArgs;
        modules = [ configPath ];
      };
    };
  };

  fileInPathExists = path: file:
    let
      paths = builtins.attrNames (builtins.readDir path);
    in
    builtins.elem file paths;

  commonAttrs = pathAttrs: pathFunction:
    let
      existingPaths = lib.filterAttrs
        (_: fileInPathExists cfg.modulesPath)
        pathAttrs;
      f = _: value: pathFunction "${cfg.modulesPath}/${value}";
    in
    builtins.mapAttrs f existingPaths;

  modulesAttrs = commonAttrs modulesDirs localLib.modulesFromDir;

  configAttrs =
    let
      specialArgs = cfg.specialArgs // { inherit (cfg) flakeInputs; };
      existingPaths = lib.filterAttrs
        (_: { folder, ... }: fileInPathExists cfg.modulesPath folder)
        configsDirs;
      toConfigs = _: { folder, function }:
        let
          configs = localLib.discoverNixOSConfigFiles "${cfg.modulesPath}/${folder}";
        in
        builtins.mapAttrs (_: function specialArgs) configs;
    in
      builtins.mapAttrs toConfigs existingPaths;

in
{
  options.sysmodules-flake = {
    modulesPath = lib.mkOption {
      type = lib.types.path;
      description = "Path with module folders configs.";
      default = builtins.toPath self;
    };
    flakeInputs = lib.mkOption {
      type = lib.types.attrs;
      default = self.inputs;
    };
    specialArgs = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
    nix-darwin = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
    };
  };
  config.flake = configAttrs // modulesAttrs;
}
