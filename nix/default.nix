{ system ? builtins.currentSystem
, crossSystem ? null
, config ? {}
, sourcesOverride ? {}
}:
let
  sources = import ./sources.nix { inherit pkgs; }
    // sourcesOverride;
  iohKNix = import sources.iohk-nix {};

  nixpkgs = if (sources ? nixpkgs)
    then (builtins.trace "Not using IOHK default nixpkgs (use 'niv drop nixpkgs' to use default for better sharing)"
      sources.nixpkgs)
    else (builtins.trace "Using IOHK default nixpkgs"
    iohKNix.nixpkgs);
  #nixpkgs = /home/clever/apps/nixpkgs-rust2;
  nixpkgsMozilla = builtins.fetchGit {
    url = https://github.com/mozilla/nixpkgs-mozilla;
    rev = "50bae918794d3c283aeb335b209efd71e75e3954";
  };
  cargo2nix = builtins.fetchGit {
    url = https://github.com/tenx-tech/cargo2nix;
    ref = "v0.8.2";
  };
  # for inclusion in pkgs:
  overlays = iohKNix.overlays.iohkNix
    # our own overlays:
    ++ [
      #(import nixpkgsMozilla)
      #(self: super: {
      #  rustc = self.latest.rustChannels.nightly.rust;
      #  cargo = self.latest.rustChannels.nightly.rust;
      #})
      (pkgs: _: with pkgs; {

        # commonLib: mix pkgs.lib with iohk-nix utils and our own:
        commonLib = lib // iohkNix
          // { inherit overlays sources; };

      })
      # And, of course, our haskell-nix-ified cabal project:
      (import ./pkgs.nix)
      (self: super: {
        openssl = super.openssl.override { coreutils = self.buildPackages.coreutils; };
        zstd = super.zstd.overrideAttrs (old: {
          patchPhase = ''
            sed -i "s/Windows.h/windows.h/" programs/timefn.h
          '';
        });
      })
    ];

  pkgs = import nixpkgs {
    inherit system crossSystem overlays;
    config = config;
  };

in pkgs
