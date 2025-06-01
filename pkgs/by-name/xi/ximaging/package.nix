{
  lib,
  stdenv,
  fetchFromGitHub,
  libjpeg,
  libpng,
  libtiff,
  libX11,
  libXinerama,
  libXt,
  motif,
}:

stdenv.mkDerivation rec {
  pname = "ximaging";
  version = "1.8";

  src = fetchFromGitHub {
    owner = "alx210";
    repo = "ximaging";
    rev = "v${version}";
    hash = "sha256-UwopxnqVbDtZ2jMfVmU9NjqX5mA0QbTO9uOe/IMpA/E=";
  };

  postPatch = ''
    substituteInPlace mf/Makefile.Linux \
      --replace-fail "PREFIX = /usr" "PREFIX = $out" \
      --replace-fail "APPLRESDIR = /etc/X11/app-defaults" "APPLRESDIR = $out/etc/X11/app-defaults"
    sed -i 's/-o *0 -g *0//' src/common.mf
  '';

  preInstall = ''
    mkdir -p $out/bin $out/etc/X11/app-defaults
  '';

  strictDeps = true;

  buildInputs = [
    libjpeg
    libpng
    libtiff
    libX11
    libXinerama
    libXt
    motif
  ];

  meta = with lib; {
    description = "Lightweight, multithreaded image viewer/browser for Unix X11/Motif";
    homepage = "http://fastestcode.org/ximaging.html";
    maintainers = with maintainers; [ noiioiu ];
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "ximaging";
  };
}
