{
  fetchFromGitHub,
  stdenv,
  lib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wavefox";
  version = "1.9.150";
  src = fetchFromGitHub {
    owner = "QNetITQ";
    repo = "WaveFox";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cFrKG9VGDda9sFcAu/6zvpsd82TUOWTTEZVoaCLt1gg=";
  };

  installPhase = ''
    runHook preInstall
    cp -r $src/chrome $out
    runHook postInstall
  '';
  meta = {
    description = "Firefox CSS Theme/Style for manual customization";
    homepage = "https://github.com/QNetITQ/WaveFox";
    license = lib.licenses.mit;
  };
})
