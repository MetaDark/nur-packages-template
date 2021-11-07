{ lib
, stdenv
, fetchFromGitHub
, cmake
, SDL2
, SDL2_mixer
, Foundation
}:

stdenv.mkDerivation rec {
  pname = "VVVVVV";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "TerryCavanagh";
    repo = "VVVVVV";
    rev = version;
    sha256 = "sha256-l0daAejDwTf01n0VjFf9Wie+ka4tjPX6LwGMQepZeJw=";
  };

  sourceRoot = "source/desktop_version";

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    SDL2
    SDL2_mixer
  ] ++ lib.optionals stdenv.isDarwin [
    Foundation
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp VVVVVV "$out/bin"
    runHook postInstall
  '';

  meta = with lib; {
    description = "A retro-styled 2D platformer";
    homepage = "https://thelettervsixtim.es";
    license = {
      fullName = "VVVVVV Source Code License v1.0";
      url = "https://github.com/TerryCavanagh/VVVVVV/blob/master/LICENSE.md";
      free = false;
      redistributable = true;
    };
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.all;
    broken = stdenv.isDarwin; # SDL2_mixer now depends on timidity which is linux only
  };
}
