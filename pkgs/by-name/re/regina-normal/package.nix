{
  lib,
  python3,
  stdenv,
  tokyocabinet,
  gcc,
  cmake,
  gmp,
  jansson,
  libxml2,
  qt6,
  cppunit,
  doxygen,
  pkg-config,
  popt,
  shared-mime-info,
  libxslt,
  graphviz,
  perl,
  databaseLibrary ? tokyocabinet, # can be built with lmdb instead
  highDim ? false, # whether or not to include triangulations of dimension 9-15
}:

stdenv.mkDerivation rec {
  pname = "regina-normal";
  version = "7.3";

  src = fetchTarball {
    # release tarball signed by Benjamin Burton
    url = "https://github.com/regina-normal/regina/releases/download/regina-${version}/regina-${version}.tar.gz";
    sha256 = "sha256-9ZQKw0J29rMmwuyw5WDNfeNaGSN++9mQBByPhj7OJQk=";
  };

  nativeBuildInputs = [
    cmake
    cppunit
    databaseLibrary
    doxygen
    gcc
    gmp
    graphviz
    jansson
    libxml2
    libxslt
    perl
    pkg-config
    popt
    python3
    qt6.qtbase
    qt6.qtsvg
    qt6.wrapQtAppsHook
    shared-mime-info
    stdenv.cc
  ];

  dependencies = [
    graphviz
    perl
    python3
  ];

  prePatch = ''
    sed -e '42i #include <cstdint>' -i \
      engine/utilities/stringutils.h \
      engine/triangulation/facepair.h
    sed -e '16i cmake_policy(SET CMP0153 OLD)' -i \
      cmake/modules/FindSharedMimeInfo.cmake
    substituteInPlace python/regina/CMakeLists.txt \
      --replace-fail '$ENV{DESTDIR}${"$"}{Python_SITELIB}' \
      "$out/${python3.sitePackages}"
    substituteInPlace python/regina-python.in \
      --replace-fail "my \$python_lib_dir = ${"''"}" \
      "my \$python_lib_dir = '$out/${python3.sitePackages}'"
  '';

  preConfigure = ''
    export PKG_CONFIG_PATH=${graphviz}/lib/pkgconfig
    export PERL_PYLIBDIR=$out/${python3.sitePackages}
  '';

  NIX_CFLAGS_COMPILE = "-I${graphviz}/include/graphviz";
  NIX_LDFLAGS = "-L${graphviz}/lib -lgvc";

  cmakeFlags = [
    "-DREGINA_INSTALL_TYPE=XDG"
    "-DPython_EXECUTABLE=${python3.interpreter}"
  ] ++ lib.optionals highDim [ "-DHIGHDIM=1" ];

  postInstall = ''
    patchShebangs $out/bin/*
  '';

  meta = {
    description = "Software for low-dimensional topology";
    homepage = "https://regina-normal.github.io";
    changelog = "https://regina-normal.github.io/#new";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ noiioiu ];
    platforms = lib.platforms.linux;
  };
}
