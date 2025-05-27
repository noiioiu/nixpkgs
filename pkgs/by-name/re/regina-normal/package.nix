{
  lib,
  stdenv,
  tokyocabinet,
  databaseLibrary ? tokyocabinet, # can be built with lmdb instead
  gcc,
  cmake,
  gmp,
  jansson,
  libxml2,
  qt6,
  cppunit,
  doxygen,
  python3,
  pkg-config,
  popt,
  shared-mime-info,
  libxslt,
  graphviz,
  perl,
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
    substituteInPlace python/regina/CMakeLists.txt \
      --replace-fail '$ENV{DESTDIR}${"$"}{Python_SITELIB}' \
      "$out/${python3.sitePackages}"
    substituteInPlace python/regina-python.in \
      --replace-fail "my \$python_lib_dir = ${"''"}" \
      "my \$python_lib_dir = '${placeholder "out"}/${python3.sitePackages}'"
  '';

  preConfigure = ''
    export PKG_CONFIG_PATH=${graphviz}/lib/pkgconfig
    export PERL_PYLIBDIR=${placeholder "out"}/${python3.sitePackages}
  '';

  NIX_CFLAGS_COMPILE = "-I${graphviz}/include/graphviz";
  NIX_LDFLAGS = "-L${graphviz}/lib -lgvc";

  cmakeFlags = [
    "-DREGINA_INSTALL_TYPE=XDG"
    "-DPERL_PYLIBDIR=${placeholder "out"}/${python3.sitePackages}"
  ];

  postInstall = ''
    patchShebangs $out/bin/*
  '';

  meta = {
    description = "Software for low-dimensional topology";
    homepage = "https://regina-normal.github.io";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ noiioiu ];
    platforms = lib.platforms.linux;
  };
}
