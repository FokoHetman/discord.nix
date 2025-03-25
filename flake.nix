{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, ...}@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (nixpkgs) lib;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.writeShellScriptBin "discordnix" ''
          echo "no impl"
        '';
        nixosModules.discord =
          { pkgs, ... }@args: {
            imports = [
              (import ./. inputs)
              {
                discord = {};
              }
            ];
          };
        homeManagerModules.discord =
          { pkgs, ... }@args: {
            imports = [
              (import ./. inputs)
              {
                discord = {};
              }
            ];
          };
      });
}
