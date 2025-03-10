{
  buildFHSEnv,
  fetchSteam,
  lib,
  makeWrapper,
  pulseaudio,
  stdenvNoCC,
  steamworks-sdk-redist,
  xdg-user-dirs,
}:
let
  binPath = lib.makeBinPath [ xdg-user-dirs ];
in
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "satisfactory-server";
  version = "16645877";

  src = fetchSteam {
    inherit (finalAttrs) name;
    appId = "1690800";
    depotId = "1690802";
    manifestId = "7240677446020425967";
    hash = "sha256-P8+s11TUX2TJ5vz5qfrGgsMJ7UfYwWeBw9owg8VuiEw=";
  };

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share $out/bin

    cp -r . $out/share/satisfactory-server
    chmod +x $out/share/satisfactory-server/Engine/Binaries/Linux/FactoryServer-Linux-Shipping

    makeWrapper \
      $out/share/satisfactory-server/Engine/Binaries/Linux/FactoryServer-Linux-Shipping \
      $out/bin/satisfactory-server \
      --add-flags "FactoryGame" \
      --prefix PATH : ${binPath}

    runHook postInstall
  '';

  passthru.fhs = buildFHSEnv {
    name = finalAttrs.name;
    runScript = lib.getExe finalAttrs.finalPackage;

    targetPkgs = pkgs: [
      finalAttrs.finalPackage
      pulseaudio
      steamworks-sdk-redist
    ];

    meta = finalAttrs.meta;
  };

  meta = with lib; {
    mainProgram = "satisfactory-server";
    description = "Satisfactory dedicated server";
    homepage = "https://steamdb.info/app/1690800/";
    changelog = "https://store.steampowered.com/news/app/526870?updates=true";
    sourceProvenance = with sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
})
