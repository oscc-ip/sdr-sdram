# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2024 Jiuyang Liu <liu@jiuyang.me>
{
  description = "Chisel Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils }:
    let overlay = import ./nix/overlay.nix;
    in {
      # System-independent attr
      inherit inputs;
      overlays.default = overlay;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          overlays = [ overlay ];
          inherit system;
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        legacyPackages = pkgs;
        devShells.default = pkgs.mkShell ({
          inputsFrom = [ pkgs.sdram.sdram-compiled pkgs.sdram.tb-dpi-lib ];
          nativeBuildInputs = [ pkgs.cargo pkgs.rustfmt pkgs.rust-analyzer pkgs.clippy pkgs.nixfmt-rfc-style pkgs.nixpkgs-fmt ];
          RUST_SRC_PATH =
            "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
        } // pkgs.sdram.tb-dpi-lib.env);
      });
}
