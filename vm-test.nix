{
  testers,
  lib,
}:

testers.runNixOSTest {
  name = "git-pages-helm";

  nodes.server =
    { pkgs, ... }:

    {
      networking.enableIPv6 = false;
      services.k3s = {
        enable = true;
        role = "server";
        extraFlags = [
          "--disable=traefik"
          "--flannel-backend=vxlan"
        ];
      };

      environment.systemPackages = [
        pkgs.kubernetes-helm
        pkgs.kubectl
        pkgs.curl
      ];
    };

  testScript = ''
    start_all()

    with subtest("test whether chart actually applies on a real cluster"):
      server.wait_for_unit("k3s.service")
      server.wait_until_succeeds("test -f /run/flannel/subnet.env")
      server.wait_until_succeeds("kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml get nodes | grep -q Ready")

      server.succeed("helm --kubeconfig=/etc/rancher/k3s/k3s.yaml install git-pages-release ${./git-pages}")
  '';

  meta.maintainers = with lib.maintainers; [
    bartoostveen
  ];
}
