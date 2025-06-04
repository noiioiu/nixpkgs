{
  lib,
  python,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools-scm,
  tkinter,
  pyopengl,
  libGL,
}:

buildPythonPackage rec {
  pname = "tkinter-gl";
  version = "1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "3-manifolds";
    repo = "tkinter_gl";
    tag = "v${version}_as_released";
    hash = "sha256-ObI8EEQ7mAOAuV6f+Ld4HH0xkFzqiAZqHDvzjwPA/wM";
  };

  build-system = [ setuptools-scm ];

  dependencies = [
    tkinter
    pyopengl
    libGL
  ];

  postInstall = ''
    cp -r ${src}/src/tkinter_gl/tk $out/${python.sitePackages}/tkinter_gl/
    patchelf --set-rpath ${lib.makeLibraryPath [ libGL ]} \
      $out/${python.sitePackages}/tkinter_gl/tk/*/*/*.so
  '';

  pythonImportsCheck = [ "tkinter_gl" ];

  meta = {
    description = "Base class for GL rendering surfaces in tkinter";
    homepage = "https://github.com/3-manifolds/tkinter_gl";
    changelog = "https://github.com/3-manifolds/tkinter_gl/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ noiioiu ];
  };
}
