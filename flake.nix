{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          bundler = pkgs.bundler;
          libffi = pkgs.libffi; # without this gem will try to build libffi (and likely to fail)
          git = pkgs.git;
        };
        formatter = pkgs.nixfmt-tree;
      }
    );
}
