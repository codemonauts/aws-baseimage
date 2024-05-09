{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    ansible-lint
    packer
    python311
    python311Packages.pip
    jq
  ];
  shellHook = ''
    packer init packer.pkr.hcl
  '';
}

