<div align="center">

# sysmodule-flake

sysmodule-flake allows you to write your NixOS, nix-darwin and home-manager configurations and write/import modules in a simple and holistic way without the need to (re-)write a lot of boiler plate code for each system.

**Developed and maintained by [Applicative Systems](https://applicative.systems/)**

<p>
<a href="https://matrix.to/#/#applicative.systems:matrix.org"><img src="https://img.shields.io/badge/Support-%23applicative.systems-blue"/></a>
</p>

</div>

The project uses [flake-parts](https://github.com/hercules-ci/flake-parts) to further extend the comfort of using one top-level flake.nix file for all system configurations.

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

    # Optional: Add this only if you use home-manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Optional: Add this only if you use nix-darwin
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

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

      # Optional: Add this only if you use nix-darwin
      inherit nix-darwin;
    };
  };
}
```

In this example, `modulesPath = ./.` is the top-level directory, but of course it can be any path within the repository. sysmodule-flake expects the following directory structure:

- `configs-nixos/`
	- `machine_00/`
		- `configuration.nix`
	- `machine_01/`
		- `configuration.nixz
	- ...
- `configs-darwin/`
	- `machine_10/`
		- `configuration.nix`
	- `machine_11/`
		- `configuration.nix`
	- ...
- `modules-home-manager/`
	- `git.nix`
	- `tmux.nix`
	- ...

## Professional Services

We offer commercial support to help you succeed with `sysmodules-flake` and our
other projects:

  * **Custom Development:** Tailored features for your needs
  * **Integration Support:** Help with your deployment workflows
  * **Training:** Expert guidance for your team
  * **Consulting:** Infrastructure optimization

Contact us:

  * 📧 [hello@applicative.systems](mailto:hello@applicative.systems)
  * 🤝 [Schedule a meeting](https://nixcademy.com/meet)

## Community

  * Join our [Matrix channel](https://matrix.to/#/#applicative.systems:matrix.org)
  * Report issues on [GitHub](https://github.com/applicative-systems/sysmodule-flake/issues)
  * Contribute via [Pull Requests](https://github.com/applicative-systems/sysmodule-flake/pulls)

## License

[MIT License](./LICENSE)
