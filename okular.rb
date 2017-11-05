require "formula"

class Okular < Formula
  desc "Document Viewer"
  homepage "https://okular.kde.org"
  url "https://download.kde.org/stable/applications/17.08.2/src/okular-17.08.2.tar.xz"
  sha256 "c56f57dc47b8c00208e374f3249d2cf69d6293cb9ebfeeb3601f1c64cbc37e56"

  head "git://anongit.kde.org/okular.git"

  depends_on "cmake" => :build
  depends_on "KDE-mac/kde/kf5-extra-cmake-modules" => :build
  depends_on "KDE-mac/kde/kf5-kdoctools" => :build
  depends_on "KDE-mac/kde/kf5-khtml" => :build

  depends_on "qt"
  depends_on "qca"
  depends_on "zlib"
  depends_on "freetype"
  depends_on "libspectre"
  depends_on "djvulibre"
  depends_on "chmlib"
  depends_on "KDE-mac/kde/kf5-kactivities"
  depends_on "KDE-mac/kde/kf5-karchive"
  depends_on "KDE-mac/kde/kf5-kbookmarks"
  depends_on "KDE-mac/kde/kf5-kcompletion"
  depends_on "KDE-mac/kde/kf5-kconfig"
  depends_on "KDE-mac/kde/kf5-kconfigwidgets"
  depends_on "KDE-mac/kde/kf5-kcoreaddons"
  depends_on "KDE-mac/kde/kf5-kdbusaddons"
  depends_on "KDE-mac/kde/kf5-kiconthemes"
  depends_on "KDE-mac/kde/kf5-kio"
  depends_on "KDE-mac/kde/kf5-kjs"
  depends_on "KDE-mac/kde/kf5-kparts"
  depends_on "KDE-mac/kde/kf5-kpty"
  depends_on "KDE-mac/kde/kf5-threadweaver"
  depends_on "KDE-mac/kde/kf5-kwallet"
  depends_on "KDE-mac/kde/kf5-kwindowsystem"
  depends_on "KDE-mac/kde/libkexiv2"

  patch :DATA

  def install
    args = std_cmake_args
    args << "-DBUILD_TESTING=OFF"
    args << "-DBUILD_QCH=ON"
    args << "-DKDE_INSTALL_QMLDIR=lib/qt5/qml"
    args << "-DKDE_INSTALL_PLUGINDIR=lib/qt5/plugins"
    args << "-DCMAKE_INSTALL_BUNDLEDIR=#{prefix}/bin"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
      prefix.install "install_manifest.txt"
    end
  end

  def caveats; <<-EOS.undent
    You need to take some manual steps in order to make this formula work (NOTE: the order is important!):
      ln -sf "$(brew --prefix)/share/okular ~/Library/"Application Support"
      ln -sf "$(brew --prefix)/share/icons/breeze/breeze-icons.rcc" ~/Library/"Application Support"/okular/icontheme.rcc
      mkdir -p ~/Applications/KDE
      ln -sf "#{prefix}/bin/okular.app" ~/Applications/KDE/
    EOS
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 7537220..5fef3d7 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -190,7 +190,7 @@ generate_export_header(okularcore BASE_NAME okularcore EXPORT_FILE_NAME "${CMAKE

 # Special handling for linking okularcore on OSX/Apple
 IF(APPLE)
-    SET(OKULAR_IOKIT "-framework IOKit" CACHE STRING "Apple IOKit framework")
+    SET(OKULAR_IOKIT "-framework CoreFoundation -framework CoreGraphics -framework IOKit" CACHE STRING "Apple IOKit framework")
 ENDIF(APPLE)

 target_link_libraries(okularcore
diff --git a/core/utils.cpp b/core/utils.cpp
index c9bfc2d..b8c955f 100644
--- a/core/utils.cpp
+++ b/core/utils.cpp
@@ -134,7 +134,7 @@ QSizeF Utils::realDpi(QWidget* widgetOnScreen)
         return err;
     }

-double Utils::realDpiX()
+static double realDpiX()
 {
     double x,y;
     CGDisplayErr err = GetDisplayDPI( CGDisplayCurrentMode(kCGDirectMainDisplay),
@@ -144,7 +144,7 @@ double Utils::realDpiX()
     return err == CGDisplayNoErr ? x : 72.0;
 }

-double Utils::realDpiY()
+static double realDpiY()
 {
     double x,y;
     CGDisplayErr err = GetDisplayDPI( CGDisplayCurrentMode(kCGDirectMainDisplay),
