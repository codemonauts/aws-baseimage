{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    packer
  ];
  shellHook = ''
    packer init packer.pkr.hcl
  '';
}

