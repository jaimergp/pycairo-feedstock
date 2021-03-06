setlocal EnableDelayedExpansion
@echo on

:: We're using the meson build system as opposed to 'pip install .' because it provides
:: the pkg-config files for `pycairo`. These are used by downstream packages (notably
:: `pygobject`) that also use the meson build system in order to locate `pycairo`.
:: Without them, `pycairo` will not be found and might be built as an in-tree subproject
:: which is obviously undesirable.

:: meson options
:: (set pkg_config_path so deps in host env can be found)
set ^"MESON_OPTIONS=^
  --prefix="%LIBRARY_PREFIX%" ^
  --pkg-config-path="%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig" ^
  --wrap-mode=nofallback ^
  --buildtype=release ^
  --backend=ninja ^
  -D python=%PYTHON% ^
 ^"

:: configure build using meson
%BUILD_PREFIX%\python.exe %BUILD_PREFIX%\Scripts\meson setup builddir !MESON_OPTIONS!
if errorlevel 1 exit 1

:: print results of build configuration
%BUILD_PREFIX%\python.exe %BUILD_PREFIX%\Scripts\meson configure builddir
if errorlevel 1 exit 1

ninja -v -C builddir
if errorlevel 1 exit 1

ninja -C builddir install
if errorlevel 1 exit 1

:: meson doesn't put the Python files in the right place, and there's no way to override
cd %LIBRARY_PREFIX%\lib\python*
cd site-packages
move *.egg-info %PREFIX%\Lib\site-packages
move cairo %PREFIX%\Lib\site-packages\cairo
