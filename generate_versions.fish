#!/usr/bin/env fish

set VERSIONS_RESP (curl \
    -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token $BUN_VERSIONS_TOKEN" \
    https://api.github.com/repos/oven-sh/bun/releases)

# echo "Got resp $VERSIONS_RESP"

# set JQ_FILTER '.[] | {tag: .tag_name} | .assets[].name as \$Name | (\$Name - \$TagId)'
# set VERSIONS (echo $VERSION_RESP | jq ".[] | .tag_name as \$TagId | .assets[].name as \$Name | (\$Name - \$TagId)")

set VERSIONS (echo $VERSIONS_RESP | jq -c ".[] | {tag: .tag_name, asset: (.assets[] | {name, browser_download_url})}")

# set VERSIONS "0.1.6" "0.1.5" "0.1.4" "0.1.3" "0.1.2" "0.1.1" "0.0.83" "0.0.81" "0.0.79" "0.0.78" 


rm versions.nix
echo "[" >> versions.nix
# echo "Got Versions"
# for VERSION in $VERSIONS
#   echo "$VERSION"
# end
# exit 0;
for VERSION in $VERSIONS
  set curr_version (echo $VERSION | jq -r ".tag" | sed 's/bun-//g')
  set curr_asset (echo $VERSION | jq -r ".asset.name")
  set curr_url (echo $VERSION | jq -r ".asset.browser_download_url")
  set curr_version_without_v (echo $curr_version | sed 's/v//g')
  set sha (nix-prefetch-url $curr_url)
  switch $curr_version
    case '*canary*'
      continue;
  end
#   {
#     version = "v0.1.6";
#     system = "x86_64-darwin";
#     url = "https://github.com/oven-sh/bun/releases/download/bun-v0.1.6/bun-darwin-x64.zip";
#     sha256 = "15145vh93z5p30f0whp7fxxl7axkbg7jr28ww7nhf0phnllmzysi";
#   }

  # take everything between "bun- .zip"
  # set system (echo $curr_asset | grep -o -P '(?<=bun-).*(?=\.zip)')
  set parsed_system (echo $curr_asset | sed "s/bun-//g; s/cli-//g; s/.dSYM//g; s/$curr_version_without_v//g; s/.zip//g; s/.tar.gz//g; s/.tgz//g;")

  if test "$parsed_system" = ""
    echo "warn: couldn't get system from: $curr_asset";
    continue;
  end

  set system "";
  
  switch $parsed_system
    case "*x64*"
      set system "x86_64"
    case "*aarch64*"
      set system "aarch64"
  end
  switch $parsed_system
    case "*darwin*"
      set system "$system-darwin"
    case "*linux*"
      set system "$system-linux"
  end

  switch $curr_asset
    case "*baseline*"
      set curr_version "$curr_version.baseline"
  end
  switch $curr_asset
    case "*profile*"
      set curr_version "$curr_version.profile"
  end
  switch $curr_asset
    case "*dSYM*"
      set curr_version "$curr_version.dSYM"
  end
  # echo $system | grep 

  # echo "$system / $curr_asset / $curr_version";

  # todo remember to add _profile to version
  echo "{" >> versions.nix;
  echo "  version = \"$curr_version\";" >> versions.nix;
  echo "  system = \"$system\";" >> versions.nix;
  echo "  url = \"$curr_url\";" >> versions.nix;
  echo "  sha256 = \"$sha\";" >> versions.nix;
  echo "}" >> versions.nix;
end
echo "]" >> versions.nix;

