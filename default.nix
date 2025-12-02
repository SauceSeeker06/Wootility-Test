{ 
  stdenv, 
  lib, 
  fetchurl, 
  appimageTools, 
  makeWrapper,
  bash
}:

let 
  pname = "wootility-test";
  version = "5.1.2";
  src = fetchurl {
    url = "https://api.wooting.io/public/wootility/download?os=linux&version=${version}";
    sha256 = "sha256-JcVyuilhy1qjXyIeniXZ0s4qxXr/4wLXrXgTTxjCkBk=";
  };
in 

appimageTools.wrapType2 {
  inherit version src;

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands =
    let
      contents = appimageTools.extract { inherit version src; };
    in
    ''
      wrapProgram $out/bin/wootility \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

      install -Dm444 wootility/wootility.desktop -t $out/share/applications
      mkdir -p $out/etc/udev/rules.d/
      cp ./*.rules $out/etc/udev/rules.d/
      substituteInPlace $out/etc/udev/rules.d/70-wootility.rules \
        --replace-fail "/bin/sh" "${bash}/bin/bash"
      
      rm $out/share/applications/wootility.desktop
      substitute wootility.desktop $out/share/applications/wootility.desktop \
        --replace-fail "/usr/bin/wootility wootility" "Exec=AppRun --no-sandbox" "Exec=wootility"
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