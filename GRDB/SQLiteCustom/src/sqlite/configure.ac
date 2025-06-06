#
# The build process allows for using a cross-compiler.  But the default
# action is to target the same platform that we are running on.  The
# configure script needs to discover the following properties of the 
# build and target systems:
#
#    srcdir
#
#        The is the name of the directory that contains the
#        "configure" shell script.  All source files are
#        located relative to this directory.
#
#    bindir
#
#        The name of the directory where executables should be
#        written by the "install" target of the makefile.
#
#    program_prefix
#
#        Add this prefix to the names of all executables that run
#        on the target machine.  Default: ""
#
#    ENABLE_SHARED
#
#        True if shared libraries should be generated.
#
#    BUILD_CC
#
#        The name of a command that is used to convert C
#        source files into executables that run on the build
#        platform.
#
#    BUILD_CFLAGS
#
#        Switches that the build compiler needs in order to construct
#        command-line programs.
#
#    BUILD_LIBS
#
#        Libraries that the build compiler needs in order to construct
#        command-line programs.
#
#    BUILD_EXEEXT
#
#        The filename extension for executables on the build
#        platform.  "" for Unix and ".exe" for Windows.
#
#    TCL_*
#
#        Lots of values are read in from the tclConfig.sh script,
#        if that script is available.  This values are used for
#        constructing and installing the TCL extension.
#
#    TARGET_READLINE_LIBS
#
#        This is the library directives passed to the target linker
#        that cause the executable to link against the readline library.
#        This might be a switch like "-lreadline" or pathnames of library
#        file like "../../src/libreadline.a".
#
#    TARGET_READLINE_INC
#
#        This variables define the directory that contain header
#        files for the readline library.  If the compiler is able 
#        to find <readline.h> on its own, then this can be blank.
#
#    TARGET_EXEEXT
#
#        The filename extension for executables on the
#        target platform.  "" for Unix and ".exe" for windows.
#
# This configure.in file is easy to reuse on other projects.  Just
# change the argument to AC_INIT.  And disable any features that
# you don't need (for example BLT) by erasing or commenting out
# the corresponding code.
#
AC_INIT([sqlite],m4_esyscmd(cat VERSION | tr -d '\n'))

dnl Make sure the local VERSION file matches this configure script
sqlite_version_sanity_check=`cat $srcdir/VERSION | tr -d '\n'`
if test "$PACKAGE_VERSION" != "$sqlite_version_sanity_check" ; then
AC_MSG_ERROR([configure script is out of date:
 configure \$PACKAGE_VERSION = $PACKAGE_VERSION
 top level VERSION file     = $sqlite_version_sanity_check
please regen with autoconf])
fi

#########
# Programs needed
#
LT_INIT
AC_PROG_INSTALL

#########
# Enable large file support (if special flags are necessary)
#
AC_SYS_LARGEFILE

#########
# Check for needed/wanted data types
AC_CHECK_TYPES([int8_t, int16_t, int32_t, int64_t, intptr_t, uint8_t,
                uint16_t, uint32_t, uint64_t, uintptr_t])

#########
# Check for needed/wanted headers
AC_CHECK_HEADERS([sys/types.h stdlib.h stdint.h inttypes.h malloc.h])

#########
# Figure out whether or not we have these functions
#
AC_CHECK_FUNCS([fdatasync gmtime_r isnan localtime_r localtime_s malloc_usable_size strchrnul usleep utime pread pread64 pwrite pwrite64])

#########
# By default, we use the amalgamation (this may be changed below...)
#
USE_AMALGAMATION=1

#########
# Figure out all the name of a working tclsh and parameters needed to compile against Tcl.
# The --with-tcl= and/or --with-tclsh= configuration arguments might be useful for this.
#
AC_ARG_WITH(tclsh, AS_HELP_STRING([--with-tclsh=PATHNAME],[full pathname of a tclsh to use]))
AC_ARG_WITH(tcl, AS_HELP_STRING([--with-tcl=DIR],[directory containing (tclConfig.sh)]))
AC_ARG_ENABLE(tcl, AS_HELP_STRING([--disable-tcl],[omit building accessory programs that require TCL-dev]),
      [use_tcl=$enableval],[use_tcl=yes])
original_use_tcl=${use_tcl}
if test x"${with_tclsh}" = x -a x"${with_tcl}" = x; then
  AC_CHECK_PROGS(TCLSH_CMD, [tclsh9.0 tclsh8.6 tclsh],none)
  with_tclsh=${TCLSH_CMD}
fi
if test x"${with_tclsh}" != x -a x"${with_tclsh}" != xnone; then
  TCLSH_CMD=${with_tclsh}
  AC_MSG_RESULT([using tclsh at "$TCLSH_CMD"])
  if test x"${use_tcl}" = "xyes"; then
    with_tcl=`${with_tclsh} <${srcdir}/tool/find_tclconfig.tcl`
    if test x"${with_tcl}" != x; then
      AC_MSG_RESULT([$TCLSH_CMD recommends the tclConfig.sh at ${with_tcl}])
    else
      AC_MSG_WARN([$TCLSH_CMD is unable to recommend a tclConfig.sh])
      use_tcl=no
    fi
  fi
fi
if test x"${use_tcl}" = "xyes"; then
  if test x"${with_tcl}" != x; then
    if test -r ${with_tcl}/tclConfig.sh; then
      tclconfig="${with_tcl}/tclConfig.sh"
    else
      for i in tcl8.6 tcl9.0 lib; do
        if test -r ${with_tcl}/$i/tclConfig.sh; then
          tclconfig=${with_tcl}/$i/tclConfig.sh
          break
        fi
      done
    fi
    if test ! -r "${tclconfig}"; then
      AC_MSG_ERROR([no tclConfig.sh file found under ${with_tcl}])
    fi
  else
    # If we have not yet found a tclConfig.sh file, look in $libdir whic is
    # set automatically by autoconf or by the --prefix command-line option.
    # See https://sqlite.org/forum/forumpost/e04e693439a22457
    libdir=${prefix}/lib
    if test -r ${libdir}/tclConfig.sh; then
      tclconfig=${libdir}/tclConfig.sh
    else
      for i in tcl8.6 tcl9.0 lib; do
        if test -r ${libdir}/$i/tclConfig.sh; then
          tclconfig=${libdir}/$i/tclConfig.sh
          break
        fi
      done
    fi
    if test ! -r "${tclconfig}"; then
      AC_MSG_ERROR([cannot find a usable tclConfig.sh file. 
        Use --with-tcl=DIR to specify a directory where tclConfig.sh can be found.
        SQLite does not use TCL internally, but TCL is required to build SQLite
        from canonical sources and TCL is required for testing.])
    fi
  fi
  AC_MSG_RESULT([loading TCL configuration from ${tclconfig}])
  . ${tclconfig}
  AC_SUBST(TCL_INCLUDE_SPEC)
  AC_SUBST(TCL_LIB_SPEC)
  AC_SUBST(TCL_STUB_LIB_SPEC)
  # There are lots of other configuration variables that are provided by the
  # tclConfig.sh file and that could be included here.  But as of right now,
  # TCL_LIB_SPEC is the only what that the Makefile uses.
  HAVE_TCL=1
elif test x"${original_use_tcl}" = "xno"; then
  AC_MSG_RESULT([unable to run tests because of --disable-tcl])
  HAVE_TCL=0
else
  AC_MSG_RESULT([unable to run tests because no tclConfig.sh file could be located])
  HAVE_TCL=0
fi
AC_SUBST(HAVE_TCL)
if test x"$TCLSH_CMD" = x; then
  TCLSH_CMD=${TCL_EXEC_PREFIX}/bin/tclsh${TCL_VERSION}
  if test ! -x ${TCLSH_CMD}; then
    TCLSH_CMD_2=${TCL_EXEC_PREFIX}/bin/tclsh
    if test ! -x ${TCLSH_CMD_2}; then
      AC_MSG_WARN([cannot find a usable tclsh at either ${TCLSH_CMD} or ${TCLSH_CMD_2}])
      TCLSH_CMD=none
    else
      TCLSH_CMD=${TCLSH_CMD_2}
    fi
  fi
fi
if test "$TCLSH_CMD" = "none"; then
  # If we can't find a local tclsh, then building the amalgamation will fail.
  # We act as though --disable-amalgamation has been used.
  AC_MSG_WARN([Warning: can't find tclsh - defaulting to non-amalgamation build.])
  USE_AMALGAMATION=0
  TCLSH_CMD="tclsh"
fi
AC_SUBST(TCLSH_CMD)

AC_ARG_VAR([TCLLIBDIR], [Where to install tcl plugin])
if test "x${TCLLIBDIR+set}" != "xset" ; then
  for i in `echo 'puts stdout $auto_path' | ${TCLSH_CMD}` ; do
    if test -d $i ; then
      TCLLIBDIR=$i
      break
    fi
  done
  TCLLIBDIR="${TCLLIBDIR}/sqlite3"
fi

#########
# Set up options for running tests.
#
AC_ARG_ENABLE(test-status, AS_HELP_STRING([--enable-test-status],[Full-screen status of tests]),
      [use_vt100=$enableval],[use_vt100=no])
if test $use_vt100 != no; then
  TSTRNNR_OPTS=--status
else
  TSTRNNR_OPTS=
fi
AC_SUBST(TSTRNNR_OPTS)


#########
# Set up an appropriate program prefix
#
if test "$program_prefix" = "NONE"; then
  program_prefix=""
fi
AC_SUBST(program_prefix)

VERSION=[`cat $srcdir/VERSION | sed 's/^\([0-9]*\.*[0-9]*\).*/\1/'`]
AC_MSG_NOTICE(Version set to $VERSION)
AC_SUBST(VERSION)
RELEASE=`cat $srcdir/VERSION`
AC_MSG_NOTICE(Release set to $RELEASE)
AC_SUBST(RELEASE)

##########
# Handle --with-wasi-sdk=DIR
#
# This must be early because it changes the toolchain.
#
AC_ARG_WITH(wasi-sdk,
AS_HELP_STRING([--with-wasi-sdk=DIR],
       [directory containing the WASI SDK. Triggers cross-compile to WASM.]), with_wasisdk=${withval})
AC_MSG_CHECKING([for WASI SDK directory])
AC_CACHE_VAL(ac_cv_c_wasi_sdk,[
  # First check to see if --with-tcl was specified.
  if test x"${with_wasi_sdk}" != x ; then
    if ! test -d "${with_wasi_sdk}" ; then
      AC_MSG_ERROR([${with_wasi_sdk} directory doesn't exist])
    fi
    AC_MSG_RESULT([${with_wasi_sdk}: using wasi-sdk clang, disabling: tcl, CLI shell, DLL])
    use_wasi_sdk=yes
  else
    use_wasi_sdk=no
  fi
])
if test "${use_wasi_sdk}" = "no" ; then
  HAVE_WASI_SDK=""
  AC_MSG_RESULT([no])
else
  HAVE_WASI_SDK=1
# Changing --host and --target have no effect here except to possibly
# cause confusion. autoconf has finished processing them by this
# point.
#
#  host_alias=wasm32-wasi
#  target=wasm32-wasi
#
# Merely changing CC and LD to the wasi-sdk's is enough to get
# sqlite3.o building in WASM format.
  CC="${with_wasi_sdk}/bin/clang"
  LD="${with_wasi_sdk}/bin/wasm-ld"
  RANLIB="${with_wasi_sdk}/bin/llvm-ranlib"
  cross_compiling=yes
  enable_threadsafe=no
  use_tcl=no
  enable_tcl=no
  # libtool is apparently hard-coded to use gcc for linking DLLs, so
  # we disable the DLL build...
  enable_shared=no
  AC_MSG_RESULT([yes])
fi
AC_SUBST(HAVE_WASI_SDK)


#########
# Locate a compiler for the build machine.  This compiler should
# generate command-line programs that run on the build machine.
#
if test x"$cross_compiling" = xno; then
	BUILD_CC=$CC
	BUILD_CFLAGS=$CFLAGS
else
	if test "${BUILD_CC+set}" != set; then
		AC_CHECK_PROGS(BUILD_CC, gcc cc cl)
	fi
	if test "${BUILD_CFLAGS+set}" != set; then
		BUILD_CFLAGS="-g"
	fi
fi
AC_SUBST(BUILD_CC)

##########
# Do we want to support multithreaded use of sqlite
#
AC_ARG_ENABLE(threadsafe, 
AS_HELP_STRING([--disable-threadsafe],[Disable mutexing]))
AC_MSG_CHECKING([whether to support threadsafe operation])
if test "$enable_threadsafe" = "no"; then
  SQLITE_THREADSAFE=0
  AC_MSG_RESULT([no])
else
  SQLITE_THREADSAFE=1
  AC_MSG_RESULT([yes])
fi
AC_SUBST(SQLITE_THREADSAFE)

if test "$SQLITE_THREADSAFE" = "1"; then
  AC_SEARCH_LIBS(pthread_create, pthread)
  AC_SEARCH_LIBS(pthread_mutexattr_init, pthread)
fi

##########
# Do we want to support release
#
AC_ARG_ENABLE(releasemode, 
AS_HELP_STRING([--enable-releasemode],[Support libtool link to release mode]),,enable_releasemode=no)
AC_MSG_CHECKING([whether to support shared library linked as release mode or not])
if test "$enable_releasemode" = "no"; then
  ALLOWRELEASE=""
  AC_MSG_RESULT([no])
else
  ALLOWRELEASE="-release `cat $srcdir/VERSION`"
  AC_MSG_RESULT([yes])
fi
AC_SUBST(ALLOWRELEASE)

##########
# Do we want temporary databases in memory
#
AC_ARG_ENABLE(tempstore, 
AS_HELP_STRING([--enable-tempstore],[Use an in-ram database for temporary tables (never,no,yes,always)]),,enable_tempstore=no)
AC_MSG_CHECKING([whether to use an in-ram database for temporary tables])
case "$enable_tempstore" in
  never ) 
    TEMP_STORE=0
    AC_MSG_RESULT([never])
  ;;
  no ) 
    TEMP_STORE=1
    AC_MSG_RESULT([no])
  ;;
  yes ) 
     TEMP_STORE=2
    AC_MSG_RESULT([yes])
  ;;
  always ) 
     TEMP_STORE=3
    AC_MSG_RESULT([always])
  ;;
  * ) 
    TEMP_STORE=1
    AC_MSG_RESULT([no])
  ;;
esac

AC_SUBST(TEMP_STORE)

###########
# Lots of things are different if we are compiling for Windows using
# the CYGWIN environment.  So check for that special case and handle
# things accordingly.
#
AC_MSG_CHECKING([if executables have the .exe suffix])
if test "$config_BUILD_EXEEXT" = ".exe"; then
  CYGWIN=yes
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(unknown)
fi
if test "$CYGWIN" != "yes"; then
  m4_warn([obsolete],
[AC_CYGWIN is obsolete: use AC_CANONICAL_HOST and check if $host_os
matches *cygwin*])dnl
AC_CANONICAL_HOST
case $host_os in
  *cygwin* ) CYGWIN=yes;;
	 * ) CYGWIN=no;;
esac

fi
if test "$CYGWIN" = "yes"; then
  BUILD_EXEEXT=.exe
else
  BUILD_EXEEXT=$EXEEXT
fi
if test x"$cross_compiling" = xno; then
  TARGET_EXEEXT=$BUILD_EXEEXT
else
  TARGET_EXEEXT=$config_TARGET_EXEEXT
fi
if test "$TARGET_EXEEXT" = ".exe"; then
  SQLITE_OS_UNIX=0
  SQLITE_OS_WIN=1
  CFLAGS="$CFLAGS -DSQLITE_OS_WIN=1"
else
  SQLITE_OS_UNIX=1
  SQLITE_OS_WIN=0
  CFLAGS="$CFLAGS -DSQLITE_OS_UNIX=1"
fi

AC_SUBST(BUILD_EXEEXT)
AC_SUBST(SQLITE_OS_UNIX)
AC_SUBST(SQLITE_OS_WIN)
AC_SUBST(TARGET_EXEEXT)

##########
# Figure out what C libraries are required to compile programs
# that use "readline()" library.
#
TARGET_READLINE_LIBS=""
TARGET_READLINE_INC=""
TARGET_HAVE_READLINE=0
TARGET_HAVE_EDITLINE=0
AC_ARG_ENABLE([editline],
	[AS_HELP_STRING([--enable-editline],[enable BSD editline support])],
	[with_editline=$enableval],
	[with_editline=auto])
AC_ARG_ENABLE([readline],
	[AS_HELP_STRING([--disable-readline],[disable readline support])],
	[with_readline=$enableval],
	[with_readline=auto])

if test x"$with_editline" != xno; then
        sLIBS=$LIBS
        LIBS=""
	TARGET_HAVE_EDITLINE=1
	AC_SEARCH_LIBS(readline,edit,[with_readline=no],[TARGET_HAVE_EDITLINE=0])
        TARGET_READLINE_LIBS=$LIBS
        LIBS=$sLIBS
fi
if test x"$with_readline" != xno; then
	found="yes"

	AC_ARG_WITH([readline-lib],
		[AS_HELP_STRING([--with-readline-lib],[specify readline library])],
		[with_readline_lib=$withval],
		[with_readline_lib="auto"])
	if test "x$with_readline_lib" = xauto; then
		save_LIBS="$LIBS"
		LIBS=""
		AC_SEARCH_LIBS(tgetent, [readline ncurses curses termcap], [term_LIBS="$LIBS"], [term_LIBS=""])
		AC_CHECK_LIB([readline], [readline], [TARGET_READLINE_LIBS="-lreadline"], [found="no"])
		TARGET_READLINE_LIBS="$TARGET_READLINE_LIBS $term_LIBS"
		LIBS="$save_LIBS"
	else
		TARGET_READLINE_LIBS="$with_readline_lib"
	fi

	AC_ARG_WITH([readline-inc],
		[AS_HELP_STRING([--with-readline-inc],[specify readline include paths])],
		[with_readline_inc=$withval],
		[with_readline_inc="auto"])
	if test "x$with_readline_inc" = xauto; then
		AC_CHECK_HEADER(readline.h, [found="yes"], [
			found="no"
			if test "$cross_compiling" != yes; then
				for dir in /usr /usr/local /usr/local/readline /usr/contrib /mingw; do
					for subdir in include include/readline; do
						AC_CHECK_FILE($dir/$subdir/readline.h, found=yes)
						if test "$found" = "yes"; then
							TARGET_READLINE_INC="-I$dir/$subdir"
							break
						fi
					done
					test "$found" = "yes" && break
				done
			fi
		])
	else
		TARGET_READLINE_INC="$with_readline_inc"
	fi

	if test x"$found" = xno; then
		TARGET_READLINE_LIBS=""
		TARGET_READLINE_INC=""
		TARGET_HAVE_READLINE=0
	else
		TARGET_HAVE_READLINE=1
	fi
fi
AC_ARG_WITH([linenoise],
            [AS_HELP_STRING([--with-linenoise=DIR],[source directory for linenoise library])],
            [with_linenoise=$withval],
            [with_linenoise="no"])
if test "x$with_linenoise" != "xno"; then
   TARGET_HAVE_READLINE=0
   TARGET_HAVE_EDITLINE=0
   TARGET_HAVE_LINENOISE=1
   TARGET_READLINE_INC="-I${with_linenoise}"
   TARGET_READLINE_LIBS="${with_linenoise}/linenoise.c"
   echo "using linenoise source code at ${with_linenoise}"
else
   TARGET_HAVE_LINENOISE=0
   echo "not using linenoise"
fi

AC_SUBST(TARGET_READLINE_LIBS)
AC_SUBST(TARGET_READLINE_INC)
AC_SUBST(TARGET_HAVE_READLINE)
AC_SUBST(TARGET_HAVE_EDITLINE)
AC_SUBST(TARGET_HAVE_LINENOISE)


##########
# Figure out what C libraries are required to compile programs
# that use "fdatasync()" function.
#
AC_SEARCH_LIBS(fdatasync, [rt])

#########
# check for debug enabled
AC_ARG_ENABLE(debug, AS_HELP_STRING([--enable-debug],[enable debugging & verbose explain]))
AC_MSG_CHECKING([build type])
if test "${enable_debug}" = "yes" ; then
  TARGET_DEBUG="-DSQLITE_DEBUG=1 -DSQLITE_ENABLE_SELECTTRACE -DSQLITE_ENABLE_WHERETRACE -O0 -Wall"
  AC_MSG_RESULT([debug])
else
  TARGET_DEBUG="-DNDEBUG"
  AC_MSG_RESULT([release])
fi
AC_SUBST(TARGET_DEBUG)

#########
# See whether we should use the amalgamation to build

AC_ARG_ENABLE(amalgamation, AS_HELP_STRING([--disable-amalgamation],
      [Disable the amalgamation and instead build all files separately]))
if test "${enable_amalgamation}" = "no" ; then
  USE_AMALGAMATION=0
fi
AC_SUBST(USE_AMALGAMATION)

#########
# Look for zlib.  Only needed by extensions and by the sqlite3.exe shell
AC_CHECK_HEADERS(zlib.h)
AC_SEARCH_LIBS(deflate, z, [HAVE_ZLIB="-DSQLITE_HAVE_ZLIB=1"], [HAVE_ZLIB=""])
AC_SUBST(HAVE_ZLIB)

#########
# See whether we should allow loadable extensions
AC_ARG_ENABLE(load-extension, AS_HELP_STRING([--disable-load-extension],
      [Disable loading of external extensions]),,[enable_load_extension=yes])
if test "${enable_load_extension}" = "yes" ; then
  OPT_FEATURE_FLAGS=""
  AC_SEARCH_LIBS(dlopen, dl)
else
  OPT_FEATURE_FLAGS="-DSQLITE_OMIT_LOAD_EXTENSION=1"
fi

##########
# Do we want to support math functions
#
AC_ARG_ENABLE(math, 
AS_HELP_STRING([--disable-math],[Disable math functions]))
AC_MSG_CHECKING([whether to support math functions])
if test "$enable_math" = "no"; then
  AC_MSG_RESULT([no])
else
  AC_MSG_RESULT([yes])
  OPT_FEATURE_FLAGS="${OPT_FEATURE_FLAGS} -DSQLITE_ENABLE_MATH_FUNCTIONS"
  AC_SEARCH_LIBS(ceil, m)
fi

##########
# Do we want to support JSON functions
#
AC_ARG_ENABLE(json, 
AS_HELP_STRING([--disable-json],[Disable JSON functions]))
AC_MSG_CHECKING([whether to support JSON functions])
if test "$enable_json" = "no"; then
  AC_MSG_RESULT([no])
  OPT_FEATURE_FLAGS="${OPT_FEATURE_FLAGS} -DSQLITE_OMIT_JSON"
else
  AC_MSG_RESULT([yes])
fi

########
# The --enable-all argument is short-hand to enable
# multiple extensions.
AC_ARG_ENABLE(all, AS_HELP_STRING([--enable-all],
      [Enable FTS4, FTS5, Geopoly, RTree, Sessions]))

##########
# Do we want to support memsys3 and/or memsys5
#
AC_ARG_ENABLE(memsys5, 
  AS_HELP_STRING([--enable-memsys5],[Enable MEMSYS5]))
AC_MSG_CHECKING([whether to support MEMSYS5])
if test "${enable_memsys5}" = "yes"; then
  OPT_FEATURE_FLAGS="${OPT_FEATURE_FLAGS} -DSQLITE_ENABLE_MEMSYS5"
  AC_MSG_RESULT([yes])
else
  AC_MSG_RESULT([no])
fi
AC_ARG_ENABLE(memsys3, 
  AS_HELP_STRING([--enable-memsys3],[Enable MEMSYS3]))
AC_MSG_CHECKING([whether to support MEMSYS3])
if test "${enable_memsys3}" = "yes" -a "${enable_memsys5}" = "no"; then
  OPT_FEATURE_FLAGS="${OPT_FEATURE_FLAGS} -DSQLITE_ENABLE_MEMSYS3"
  AC_MSG_RESULT([yes])
else
  AC_MSG_RESULT([no])
fi

#########
# See whether we should enable Full Text Search extensions
AC_ARG_ENABLE(fts3, AS_HELP_STRING([--enable-fts3],
      [Enable the FTS3 extension]))
AC_MSG_CHECKING([whether to support FTS3])
if test "${enable_fts3}" = "yes" ; then
  OPT_FEATURE_FLAGS="${OPT_FEATURE_FLAGS} -DSQLITE_ENABLE_FTS3"
  AC_MSG_RESULT([yes])
else
  AC_MSG_RESULT([no])
fi
AC_ARG_ENABLE(fts4, AS_HELP_STRING([--enable-fts4],
      [Enable the FTS4 extension]))
AC_MSG_CHECKING([whether to support FTS4])
if test "${enable_fts4}" = "yes" -o "${enable_all}" = "yes" ; then
  AC_MSG_RESULT([yes])
  OPT_FEATURE_FLAGS="${OPT_FEATURE_FLAGS} -DSQLITE_ENABLE_FTS4"
  AC_SEARCH_LIBS([log],[m])
else
  AC_MSG_RESULT([no])
fi
AC_ARG_ENABLE(fts5, AS_HELP_STRING([--enable-fts5],
      [Enable the FTS5 extension]))
AC_MSG_CHECKING([whether to support FTS5])
if test "${enable_fts5}" = "yes" -o "${enable_all}" = "yes" ; then
  AC_MSG_RESULT([yes])
  OPT_FEATURE_FLAGS="${OPT_FEATURE_FLAGS} -DSQLITE_ENABLE_FTS5"
  AC_SEARCH_LIBS([log],[m])
else
  AC_MSG_RESULT([no])
fi

#########
# See whether we should enable the LIMIT clause on UPDATE and DELETE
# statements.
AC_ARG_ENABLE(update-limit, AS_HELP_STRING([--enable-update-limit],
      [Enable the UPDATE/DELETE LIMIT clause]))
AC_MSG_CHECKING([whether to support LIMIT on UPDATE and DELETE statements])
if test "${enable_update_limit}" = "yes" ; then
  OPT_FEATURE_FLAGS="${OPT_FEATURE_FLAGS} -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT"
  AC_MSG_RESULT([yes])
else
  AC_MSG_RESULT([no])
fi

#########
# See whether we should enable GEOPOLY
AC_ARG_ENABLE(geopoly, AS_HELP_STRING([--enable-geopoly],
      [Enable the GEOPOLY extension]),
      [enable_geopoly=yes],[enable_geopoly=no])
AC_MSG_CHECKING([whether to support GEOPOLY])
if test "${enable_geopoly}" = "yes" -o "${enable_all}" = "yes" ; then
  OPT_FEATURE_FLAGS="${OPT_FEATURE_FLAGS} -DSQLITE_ENABLE_GEOPOLY"
  enable_rtree=yes
  AC_MSG_RESULT([yes])
else
  AC_MSG_RESULT([no])
fi

#########
# See whether we should enable RTREE
AC_ARG_ENABLE(rtree, AS_HELP_STRING([--enable-rtree],
      [Enable the RTREE extension]))
AC_MSG_CHECKING([whether to support RTREE])
if test "${enable_rtree}" = "yes" ; then
  OPT_FEATURE_FLAGS="${OPT_FEATURE_FLAGS} -DSQLITE_ENABLE_RTREE"
  AC_MSG_RESULT([yes])
else
  AC_MSG_RESULT([no])
fi

#########
# See whether we should enable the SESSION extension
AC_ARG_ENABLE(session, AS_HELP_STRING([--enable-session],
      [Enable the SESSION extension]))
AC_MSG_CHECKING([whether to support SESSION])
if test "${enable_session}" = "yes" -o "${enable_all}" = "yes" ; then
  OPT_FEATURE_FLAGS="${OPT_FEATURE_FLAGS} -DSQLITE_ENABLE_SESSION"
  OPT_FEATURE_FLAGS="${OPT_FEATURE_FLAGS} -DSQLITE_ENABLE_PREUPDATE_HOOK"
  AC_MSG_RESULT([yes])
else
  AC_MSG_RESULT([no])
fi

#########
# attempt to duplicate any OMITS and ENABLES into the ${OPT_FEATURE_FLAGS} parameter
for option in $CFLAGS $CPPFLAGS
do
  case $option in
    -DSQLITE_OMIT*) OPT_FEATURE_FLAGS="$OPT_FEATURE_FLAGS $option";;
    -DSQLITE_ENABLE*) OPT_FEATURE_FLAGS="$OPT_FEATURE_FLAGS $option";;
  esac
done
AC_SUBST(OPT_FEATURE_FLAGS)


# attempt to remove any OMITS and ENABLES from the $(CFLAGS) parameter
ac_temp_CFLAGS=""
for option in $CFLAGS
do
  case $option in
    -DSQLITE_OMIT*) ;;
    -DSQLITE_ENABLE*) ;;
    *) ac_temp_CFLAGS="$ac_temp_CFLAGS $option";;
  esac
done
CFLAGS=$ac_temp_CFLAGS


# attempt to remove any OMITS and ENABLES from the $(CPPFLAGS) parameter
ac_temp_CPPFLAGS=""
for option in $CPPFLAGS
do
  case $option in
    -DSQLITE_OMIT*) ;;
    -DSQLITE_ENABLE*) ;;
    *) ac_temp_CPPFLAGS="$ac_temp_CPPFLAGS $option";;
  esac
done
CPPFLAGS=$ac_temp_CPPFLAGS


# attempt to remove any OMITS and ENABLES from the $(BUILD_CFLAGS) parameter
ac_temp_BUILD_CFLAGS=""
for option in $BUILD_CFLAGS
do
  case $option in
    -DSQLITE_OMIT*) ;;
    -DSQLITE_ENABLE*) ;;
    *) ac_temp_BUILD_CFLAGS="$ac_temp_BUILD_CFLAGS $option";;
  esac
done
BUILD_CFLAGS=$ac_temp_BUILD_CFLAGS


#########
# See whether we should use GCOV
AC_ARG_ENABLE(gcov, AS_HELP_STRING([--enable-gcov],
      [Enable coverage testing using gcov]))
if test "${use_gcov}" = "yes" ; then
  USE_GCOV=1
else
  USE_GCOV=0
fi
AC_SUBST(USE_GCOV)

#########
# Enable/disabled amalagamation line macros
########
AMALGAMATION_LINE_MACROS=--linemacros=0
if test "${amalgamation_line_macros}" = "yes" ; then
  AMALGAMATION_LINE_MACROS=--linemacros=1
fi
if test "${amalgamation_line_macros}" = "no" ; then
  AMALGAMATION_LINE_MACROS=--linemacros=0
fi
AC_SUBST(AMALGAMATION_LINE_MACROS)

#########
# Output the config header
AC_CONFIG_HEADERS(sqlite_cfg.h)

#########
# Generate the output files.
#
AC_SUBST(BUILD_CFLAGS)
AC_CONFIG_FILES([
Makefile
sqlite3.pc
])
AC_OUTPUT
