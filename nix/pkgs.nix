# our packages overlay
pkgs: _: with pkgs; let
  #naersk = pkgs.callPackage pkgs.commonLib.sources.naersk {};
  naersk = pkgs.callPackage ~/iohk/naersk {};
  filter = name: type: let
    baseName = baseNameOf (toString name);
    sansPrefix = lib.removePrefix (toString ../.) name;
  in
    (type == "directory") ||
    (lib.hasSuffix ".rs" name) ||
    (baseName == "Cargo.lock") ||
    (baseName == "Cargo.toml");
  src = lib.cleanSourceWith {
    inherit filter;
    src = ../.;
    name = "kes-mmm-sumed25519";
  };
in {
  jormungandr = naersk.buildPackage {
    root = ../.;
    copyBins = true;
    copyTarget = false;
    copyLibs = true;
    buildInputs = [ pkgs.openssl pkgs.pkgconfig pkgs.rustfmt ];
    PROTOC = "${protobuf}/bin/protoc";
  };
}
