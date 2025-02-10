{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible-lint
    packer
    python311
    python311Packages.pip
    jq
    yamllint
  ];
  shellHook = ''
    packer init baseimage.pkr.hcl
    packer init webserver.pkr.hcl
  '';
}

