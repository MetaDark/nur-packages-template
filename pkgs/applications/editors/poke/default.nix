{ lib
, stdenv
, fetchurl
, gettext
, help2man
, pkg-config
, texinfo
, boehmgc
, readline
, guiSupport ? false, makeWrapper, tcl, tcllib, tk
, miSupport ? true, json_c
, nbdSupport ? !stdenv.isDarwin, libnbd
, textStylingSupport ? true
, dejagnu

# update script only
, writeScript
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;
in stdenv.mkDerivation rec {
  pname = "poke";
  version = "2.4";

  src = fetchurl {
    url = "mirror://gnu/${pname}/${pname}-${version}.tar.gz";
    sha256 = "sha256-hB4oWRfGc4zpgqaTDjDr6t7PsGVaedkYTxb4dqn+bkc=";
  };

  outputs = [ "out" "dev" "info" "lib" "man" ];

  postPatch = ''
    patchShebangs .
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    help2man
    pkg-config
    texinfo
  ] ++ lib.optionals guiSupport [
    makeWrapper
    tcl.tclPackageHook
  ];

  buildInputs = [ boehmgc readline ]
  ++ lib.optionals guiSupport [ tcl tcllib tk ]
  ++ lib.optional miSupport json_c
  ++ lib.optional nbdSupport libnbd
  ++ lib.optional textStylingSupport gettext
  ++ lib.optional (!isCross) dejagnu;

  configureFlags = [
    # libpoke depends on $datadir/poke, so we specify the datadir in
    # $lib, and later move anything else it doesn't depend on to $out
    "--datadir=${placeholder "lib"}/share"
  ] ++ lib.optionals guiSupport [
    "--enable-gui"
    "--with-tcl=${tcl}/lib"
    "--with-tk=${tk}/lib"
    "--with-tkinclude=${tk.dev}/include"
  ];

  enableParallelBuilding = true;

  doCheck = !isCross;
  checkInputs = lib.optionals (!isCross) [ dejagnu ];

  postInstall = ''
    moveToOutput share/emacs "$out"
    moveToOutput share/vim "$out"
  '';

  postFixup = lib.optionalString guiSupport ''
    wrapProgram "$out/bin/poke-gui" \
      --prefix TCLLIBPATH ' ' "$TCLLIBPATH"

    # Prevent tclPackageHook from auto-wrapping all binaries, we only
    # need to wrap poke-gui
    unset TCLLIBPATH
  '';

  passthru = {
    updateScript = writeScript "update-poke" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl pcre common-updater-scripts

      set -eu -o pipefail

      # Expect the text in format of '<a href="...">poke 2.0</a>'
      new_version="$(curl -s https://www.jemarch.net/poke |
          pcregrep -o1 '>poke ([0-9.]+)</a>')"
      update-source-version ${pname} "$new_version"
    '';
  };

  meta = with lib; {
    description = "Interactive, extensible editor for binary data";
    homepage = "http://www.jemarch.net/poke";
    changelog = "https://git.savannah.gnu.org/cgit/poke.git/plain/ChangeLog?h=releases/poke-${version}";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ AndersonTorres kira-bruneau ];
    platforms = platforms.unix;

    # Undefined symbols for architecture arm64:
    #   "_jitter_print_context_kind_destroy", referenced from:
    #       _jitter_print_libtextstyle_finalize in libjitter-libtextstyle.a(jitter-print-libtextstyle.o)
    #   "_jitter_print_context_kind_make_trivial", referenced from:
    #       _jitter_print_libtextstyle_initialize in libjitter-libtextstyle.a(jitter-print-libtextstyle.o)
    #   "_jitter_print_context_make", referenced from:
    #       _jitter_print_context_make_libtextstyle in libjitter-libtextstyle.a(jitter-print-libtextstyle.o)
    #      (maybe you meant: _jitter_print_context_make_libtextstyle)
    #   "_ostream_flush", referenced from:
    #       _jitter_print_context_libtextstyle_flush in libjitter-libtextstyle.a(jitter-print-libtextstyle.o)
    #   "_ostream_write_mem", referenced from:
    #       _jitter_print_context_libtextstyle_print_chars in libjitter-libtextstyle.a(jitter-print-libtextstyle.o)
    #   "_styled_ostream_begin_use_class", referenced from:
    #       _jitter_print_context_libtextstyle_begin_decoration in libjitter-libtextstyle.a(jitter-print-libtextstyle.o)
    #   "_styled_ostream_end_use_class", referenced from:
    #       _jitter_print_context_libtextstyle_end_decoration in libjitter-libtextstyle.a(jitter-print-libtextstyle.o)
    #   "_styled_ostream_set_hyperlink", referenced from:
    #       _jitter_print_context_libtextstyle_begin_decoration in libjitter-libtextstyle.a(jitter-print-libtextstyle.o)
    #       _jitter_print_context_libtextstyle_end_decoration in libjitter-libtextstyle.a(jitter-print-libtextstyle.o)
    # ld: symbol(s) not found for architecture arm64
    badPlatforms = [ "aarch64-darwin" ];
  };
}

# TODO: Enable guiSupport by default once it's more than just a stub
