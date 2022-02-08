{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    chefdk
    packer
  ];
  shellHook = ''
    packer init packer.pkr.hcl
  '';
}

