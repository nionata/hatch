{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          # Add rust-analyzer before the rustup rust-analyzer shim to avoid infinit recursion.
          # There is no rust-analyzer in the esp toolchain. The rustup shim will try to fallback
          # to other packages on the path. It will only find itself and death spiral.
          rust-analyzer

          # rustup is required by espup to install and manage the esp toolchain.
          # RUSTUP_HOME is scoped to the project directory below.
          rustup

          # Manages the Espressif Rust fork (Xtensa target).
          # Respects $RUSTUP_HOME — set below to keep it project-local.
          espup

          # Flash firmware to the device over USB/serial
          espflash

          # Linker proxy required by esp-idf-sys (both std and no_std)
          ldproxy

          # JTAG/SWD debugging
          probe-rs-tools

          # Generate new crates from esp-rs templates
          cargo-generate

          # ESP-IDF std builds need these to compile the C SDK
          cmake
          ninja
          python3

          # General build tooling
          pkg-config
          git
        ];

        # Required for esp-idf-sys to locate libclang when generating bindings
        LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

        shellHook = ''
          # Keep all toolchain state inside the project tree, not $HOME.
          # RUSTUP_HOME and CARGO_HOME override rustup/cargo path resolution.
          # espup derives its remaining paths ($HOME/.espup, $HOME/export-esp.sh)
          # from HOME itself, so we redirect HOME for that one invocation only.
          export RUSTUP_HOME="$PWD/.rustup"
          export CARGO_HOME="''${CARGO_HOME:-$HOME/.cargo}"

          if ! rustup toolchain list 2>/dev/null | grep -q "^esp"; then
            echo "→ Xtensa toolchain absent — installing via espup (this runs once)"
            HOME="$PWD" espup install
            [ -f "$PWD/export-esp.sh" ] && mv "$PWD/export-esp.sh" "$PWD/.export-esp.sh"
          fi

          if [ -f "$PWD/.export-esp.sh" ]; then
            source "$PWD/.export-esp.sh"
          fi

          # Point rust-analyzer at the esp toolchain's stdlib source
          export RUST_SRC_PATH="$RUSTUP_HOME/toolchains/esp/lib/rustlib/src/rust/library"

          echo "hatch ESP32 dev shell — toolchain: $(rustup show active-toolchain 2>/dev/null || echo 'esp')"
        '';
      };

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
