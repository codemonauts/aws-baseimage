{ pkgs ? import <nixpkgs> {
  config.allowUnfree = true;
} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible-lint
    packer
    python313
    python313Packages.pip
    jq
    yamllint
  ];
  shellHook = ''
    packer init baseimage.pkr.hcl
    packer init webserver.pkr.hcl
  '';
}

