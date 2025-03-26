{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    flake-utils = {
      inputs.systems.follows = "systems";
      url = "github:numtide/flake-utils";
    };
  };
  outputs =
    {
      nixpkgs,
      self,
      ...
    }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit (nixpkgs) lib;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {

      })
  // {
    nixosModules.discord =
        { pkgs, ... }@args:
        {
          imports = [
            (import ./. inputs pkgs)
            {
              discord = {
                
              };
            }
          ];
        };
  };
}
