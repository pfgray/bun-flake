nixpkgs:
  let
    targets = {
      aarch64-darwin = "darwin-aarch64";
      aarch64-linux = "linux-aarch64";
      x86_64-darwin = "darwin-x64";
      x86_64-linux = "linux-x64";
    };
    mkBun = {url, sha256, version, system, ... }:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # target = builtins.trace ("converting " + system + " into: " + targets.${system}) targets.${system};
        # fixedVersion = if version == "canary" then "canary" else "bun-${version}";
        # zipFilename = "bun-${target}";
        # url = "https://github.com/oven-sh/bun/releases/download/${fixedVersion}/${zipFilename}.zip";
        zip = builtins.fetchurl {
          inherit sha256 url;
          # sha256 = "15145vh93z5p30f0whp7fxxl7axkbg7jr28ww7nhf0phnllmzysa";
          # sha256 = "1gwmxw0a2vdvcsr55n9mj5n90lh339jhcij4pa25by3s8qhc9x1k";
        };
        extractDir = builtins.replaceStrings [".zip"] [""] (builtins.baseNameOf url);
      in pkgs.stdenv.mkDerivation {
        name = "bun";
        src = ./.;
        buildInputs = [pkgs.unzip];
        installPhase = ''
          mkdir -p $out
          unzip ${zip} -d $out
          mv $out/${extractDir} $out/bin
          # cp -R $src $out
        '';
      };
  in mkBun
