lib:

let
  discoverNixOSConfigFiles = dir:
    let
      inherit (builtins)
        attrNames
        filter
        listToAttrs
        ;
      names = attrNames (
        lib.filterAttrs
          (_: v: v == "directory")
          (builtins.readDir dir)
      );
      hasConfigurationNix = name:
        builtins.readDir "${dir}/${name}" ? "configuration.nix";
      namesWithConfigs = filter hasConfigurationNix names;
      toAttrItem = name: {
        inherit name;
        value = "${dir}/${name}/configuration.nix";
      };
    in
    listToAttrs (map toAttrItem namesWithConfigs);

  toNixOSSystem = specialArgs: configPath:
    lib.nixosSystem {
      inherit specialArgs;
      modules = [ configPath ];
    };
in

{
  inherit
    discoverNixOSConfigFiles
    toNixOSSystem
    ;

  discoverNixOSConfigs = specialArgs: dir:
    let
      configs = discoverNixOSConfigFiles dir;
    in
    builtins.mapAttrs (_: toNixOSSystem specialArgs) configs;

  modulesFromDir =
    let
      getNixFilesInDir = dir: builtins.filter
        (file: lib.hasSuffix ".nix" file && file != "default.nix")
        (builtins.attrNames (builtins.readDir dir));
      genKey = str: lib.replaceStrings [ ".nix" ] [ "" ] str;
      moduleFrom = dir: str: { "${genKey str}" = "${dir}/${str}"; };
    in
    dir:
    builtins.foldl' (x: y: x // (moduleFrom dir y)) { } (getNixFilesInDir dir);
}
