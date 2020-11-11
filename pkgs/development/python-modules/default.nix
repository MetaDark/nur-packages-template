{ mergedPkgs, pythonPackages }:

mergedPkgs.lib.fix (self:
let
  mergedPythonPackages = pythonPackages // self;
  callPackage = mergedPkgs.newScope mergedPythonPackages;
in
with mergedPythonPackages; {
  inherit callPackage;

  aamp = callPackage ./aamp { };

  botw-havok = callPackage ./botw-havok { };

  debugpy = callPackage ./debugpy { };

  oead = callPackage ./oead {
    inherit (mergedPkgs) cmake;
  };

  pygls = callPackage ./pygls { };

  pytest-datadir = callPackage ./pytest-datadir { };

  vdf = callPackage ./vdf { };
})
