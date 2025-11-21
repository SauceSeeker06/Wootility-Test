{ 
  stdenv, 
  lib, 
  fetchurl, 
  appimageTools, 
  makeWrapper
}:


let
  pname = "wootility";
  version = "5.1.2";
  src = fetchurl {
    url = "https://api.wooting.io/public/${pname}/download?os=linux&version=${version}";
    sha256 = "sha256-JcVyuilhy1qjXyIeniXZ0s4qxXr/4wLXrXgTTxjCkBk=";
  };

  rules = fetchurl {
    "https://github.com/SauceSeeker06/Wootility-Test/blob/master/wootility-rules.nix"
  };


in
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
        install -Dpm644 $src etc/udev/rules.d/70-wooting.rules
        substituteInPlace $out/share/applications/wootility.desktop \
          --replace-fail 'Exec=AppRun --no-sandbox' 'Exec=wootility'
      '';

    profile = ''
      export LC_ALL=C.UTF-8
    '';

    services.udev.packages = [
      rules
  ];

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