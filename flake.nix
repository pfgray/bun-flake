
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
        versionMap = builtins.listToAttrs (map (v: {name = v.version; value = mkBunApp v;}) versionsForSystem);
      in {
        apps = versionMap;
      }
        # for each thing in $versions which supports this system,
        #   get the version, apps."${version}" = flake-utils.lib.mkApp { drv = mkBun {} }
    );
    # flake-utils.lib.eachDefaultSystem (system: let
    #   pkgs = nixpkgs.legacyPackages.${system};
    #   bun = mkBun {
    #     version = "v0.1.5";
    #     dsym = false;
    #     baseline = false;
    #     profile = false;
    #     sha256 = "1gwmxw0a2vdvcsr55n9mj5n90lh339jhcij4pa25by3s8qhc9x1k";
    #   };
    # in rec {
    #   packages = {
    #     bun = bun;
    #   };
    #   apps.bun = flake-utils.lib.mkApp {
    #     drv = bun;
    #   };
    #   apps.default = apps.bun;
    #   # apps.default = bun;
    #   # defaultApp = bun;
    # });
}
