{
  stdenv,
  kubernetes-helm,
  lib,
  version ? "unknown",
}:

stdenv.mkDerivation {
  pname = "git-pages-chart.tar.gz";
  inherit version;

  src = ./.;

  nativeBuildInputs = [
    kubernetes-helm
  ];

  buildPhase = ''
    runHook preBuild
    helm lint git-pages
    helm package git-pages
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp *.tgz $out
    runHook postInstall
  '';

  meta = {
    description = "git-pages Helm chart";
    homepage = "https://git.bartoostveen.nl/bart/git-pages-chart.git";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bartoostveen ];
    platforms = lib.platforms.all;
  };
}
