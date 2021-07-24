{ lib
, buildPythonPackage
, fetchFromGitHub
, colorama
, numpy
, oead
, isPy3k
}:

buildPythonPackage rec {
  pname = "botw-havok";
  version = "0.3.18";

  src = fetchFromGitHub {
    owner = "krenyy";
    repo = "botw_havok";
    rev = "dc7966c7780ef8c8a35e061cd3aacc20020fa2d7";
    hash = "sha256-eUbs8Ip/2S1cGQbmL0D5d1uTAF9TvnAzIxQE2tdnltI=";
  };

  patches = [
    ./loosen-requirements.patch
  ];

  propagatedBuildInputs = [
    colorama
    numpy
    oead
  ];

  # No tests
  doCheck = false;
  pythonImportsCheck = [ "botw_havok" ];

  meta = with lib; {
    description = "A library for manipulating Breath of the Wild Havok packfiles";
    homepage = "https://github.com/krenyy/botw_havok";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ kira-bruneau ];
    broken = !isPy3k;
  };
}
