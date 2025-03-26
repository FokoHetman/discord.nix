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
  {
    nixosModules.discord = { pkgs, lib, config, options, ... }@args: 
        import ./. {inherit pkgs lib config options;};
  };
}
