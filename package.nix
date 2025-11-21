# ./wootility-package.nix
{ 
  stdenv, 
  lib, 
  fetchurl, 
  appimageTools, 
  makeWrapper,
  pkgs # Make sure pkgs is passed in if this is a standalone file
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wootility";
  version = "5.1.2";

  src = fetchurl {
    url = "https://api.wooting.io/public/${pname}/download?os=linux&version=${version}";
    sha256 = "sha256-JcVyuilhy1qjXyIeniXZ0s4qxXr/4wLXrXgTTxjCkBk=";
  };

  rules = fetchurl {
    url = "https://raw.githubusercontent.com/SauceSeeker06/Wootility-Test/refs/heads/master/rules.txt";
    sha256 = "sha256-Gu/3D/jvlKZWh23BjCLYRjV78Y/Bv/rI6l2rbAjWu74=";
  };

  appimageTools.wrapType2 {
    inherit pname version src;

    nativeBuildInputs = [ makeWrapper ];

    extraInstallCommands =
      let
        contents = appimageTools.extract { inherit pname version src; };
      in
      ''
        wrapProgram $out/bin/wootility \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

        install -Dm444 ${contents}/wootility.desktop -t $out/share/applications
        install -Dm444 ${contents}/wootility.png -t $out/share/pixmaps
        substituteInPlace $out/share/applications/wootility.desktop \
          --replace-fail 'Exec=AppRun --no-sandbox' 'Exec=wootility'
      '';

    profile = ''
      export LC_ALL=C.UTF-8
    '';

    extraPkgs =
      pkgs: with pkgs; [
        xorg.libxkbfile
      ];

    meta = {
      homepage = "https://wooting.io/wootility";
      description = "Customization and management software for Wooting keyboards";
      platforms = lib.platforms.linux;
      license = lib.licenses.free;
      maintainers = with lib.maintainers; [
        sodiboo
        returntoreality
      ];
      mainProgram = "wootility";
    };
  }
})