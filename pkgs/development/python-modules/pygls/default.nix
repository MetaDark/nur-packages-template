{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, setuptools-scm
, pydantic
, toml
, typeguard
, mock
, pytest-asyncio
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pygls";
  version = "0.12";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "openlawlibrary";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-PEfGxOUsiZ5WLmoQkOP2RRWJlIKi+42lOu55C3C+k8A=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;
  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    pydantic
    toml
    typeguard
  ];

  checkInputs = [
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  # Fixes hanging tests on Darwin
  __darwinAllowLocalNetworking = true;

  pythonImportsCheck = [ "pygls" ];

  meta = with lib; {
    description = "Pythonic generic implementation of the Language Server Protocol";
    homepage = "https://github.com/openlawlibrary/pygls";
    license = licenses.asl20;
    maintainers = with maintainers; [ kira-bruneau ];
  };
}
