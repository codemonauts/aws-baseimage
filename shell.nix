{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible-lint
    just
    packer
    python313
    python313Packages.pip
    yamllint
  ];
  shellHook = ''
  '';
}

