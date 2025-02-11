# sysmodule-flake
sysmodule-flake uses [flake-parts](https://github.com/hercules-ci/flake-parts) to further extend the comfort of using one top-level flake.nix file for all system configurations.

It collects all configurations and modules in the project, found in a pre-defined directory structure (see [Usage](#Usage)). These can be any combination of NixOS configurations, [nix-darwin](https://github.com/LnL7/nix-darwin) configurations and NixOS modules to be imported in the configurations or as [home-manager](https://github.com/nix-community/home-manager) modules. 
The configuration that applies to the current system is selected and applied automatically during evaluation.

# Usage

Add sysmodule-flake to your configuration's flake inputs and define the `sysmodules-flake` attribute in the outputs as shown in the following example:

```nix
# flake.nix

{
  description = "Dummy NixOS (+ nix-darwin + home-manager) config";

  inputs = 
  {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    sysmodule-flake.url = "github:applicative-systems/sysmodule-flake";
    sysmodule-flake.inputs.nixpkgs.follows = "nixpkgs";
    sysmodule-flake.inputs.flake-parts.follows = "flake-parts";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux", "x86_64-darwin" "aarch64-darwin" ];
    imports = [
      inputs.sysmodule-flake.flakeModules.default
    ];
    sysmodules-flake = {
      modulesPath = ./.;
      specialArgs.self = inputs.self;
      nix-darwin = inputs.darwin;
    };
  };
}
```

In this example, `modulesPath = ./.` is the top-level directory, but of course it can be any path within the repository. sysmodule-flake expects the following directory structure:

- configs-nixos
	- machine_00
		- configuration.nix
	- machine_01
		- configuration.nix
	- ...
- configs-darwin
	- machine_10
		- configuration.nix
	- machine_11
		- configuration.nix
	- ...
- modules-home-manager
	- git.nix
	- tmux.nix
	- ...

Now you can start writing your configs and write/import modules and setup any machine in a simple and holistic way without the need to (re-)write a lot of boiler plate code for each system.
