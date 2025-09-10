{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
    buildInputs = [
        pkgs.bundler
        pkgs.libffi # without this gem will try to build libffi (and likely to fail)
        pkgs.git
    ];
}