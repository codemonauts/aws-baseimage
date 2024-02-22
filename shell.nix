{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    ansible-lint
    packer
  ];
  shellHook = ''
    packer init packer.pkr.hcl
  '';
}

