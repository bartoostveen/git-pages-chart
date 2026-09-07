{
  description = "Helm chart for git-pages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:

    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "aarch64-linux"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        {
          self',
          pkgs,
          lib,
          ...
        }:

        let
          inherit (lib)
            getExe
            trim
            ;

          version =
            pkgs.runCommand "git-pages-chart-version" { } ''
              ${getExe pkgs.yq} -r '.version' ${./git-pages/Chart.yaml} > $out
            ''
            |> builtins.readFile
            |> trim;
        in
        {
          treefmt = {
            programs.nixfmt.enable = true;
            programs.statix.enable = true;
            programs.deadnix.enable = true;
            programs.shellcheck.enable = true;
            programs.yamlfmt = {
              enable = true;
              includes = [ "**/*/values.yaml" ];
            };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              kubectl
              kustomize
              kubernetes-helm
              python314Packages.towncrier
              self'.packages.tag-release
            ];
          };

          checks = {
            inherit (self'.packages) chart;
            render = pkgs.runCommand "rendered-chart" { } ''
              ${getExe pkgs.kubernetes-helm} install --dry-run=client --debug test-release ${./git-pages} > $out
            '';
            e2e = pkgs.callPackage ./vm-test.nix { };
          };

          packages = {
            default = pkgs.callPackage ./package.nix { inherit version; };
            chart = self'.packages.default;

            towncrier-build = pkgs.writeShellApplication {
              name = "towncrier-build";
              runtimeInputs = [ pkgs.python314Packages.towncrier ];
              text = ''
                version=$(nix eval --raw .#default.version)
                towncrier build --version "$version" --yes "$@"
              '';
            };
            get-changelog = pkgs.writeShellApplication {
              name = "get-changelog";
              runtimeInputs = [
                pkgs.coreutils
                pkgs.git
              ];
              text = ''
                git diff HEAD~ HEAD -- CHANGELOG.md | grep '^[+]' | sed 's/^+//' | tail -n +3
              '';
            };
            tag-release = pkgs.writeShellApplication {
              name = "tag-release";
              runtimeInputs = [
                pkgs.git
                self'.packages.towncrier-build
              ];
              text = ''
                towncrier-build
                version=$(nix eval --raw .#default.version)
                git add .
                git commit -m "chore: Release $version"
                git tag "v$version" -m "Release $version"
                git show
              '';
            };
          };
        };
    };
}
