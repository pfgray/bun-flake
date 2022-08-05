
{
  description = "An Algebraic Data Type generator for Typescript";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      mkBun = import ./mkBun.nix nixpkgs;
      versions = import ./versions.nix;
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        escapeVersion = builtins.replaceStrings ["."] ["_"];
        fixedVersions = builtins.map (builtins.mapAttrs (name: value: if name == "version" then (escapeVersion value) else value)) versions;
        versionsForSystem = builtins.filter (v: v.system == system) fixedVersions;
        mkBunApp = v: flake-utils.lib.mkApp { drv = mkBun v; };
        mapViaVersion = f: vs: builtins.listToAttrs (map (v: {name = v.version; value = f v;}) vs);

      in {
        apps = mapViaVersion mkBunApp versionsForSystem;
        packages = mapViaVersion mkBun versionsForSystem;
      }
    );
}
