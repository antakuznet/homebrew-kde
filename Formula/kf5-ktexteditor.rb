class Kf5Ktexteditor < Formula
  desc "Advanced embeddable text editor"
  homepage "https://www.kde.org"
  url "https://download.kde.org/stable/frameworks/5.69/ktexteditor-5.69.0.tar.xz"
  sha256 "1662301dd318b7f20f8bf5d402e7628e4ff3012ecb7887d8bf7194e7b9a9c219"
  head "git://anongit.kde.org/ktexteditor.git"

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "graphviz" => :build
  depends_on "KDE-mac/kde/kf5-extra-cmake-modules" => :build
  depends_on "ninja" => :build

  depends_on "editorconfig"
  depends_on "KDE-mac/kde/kf5-kparts"
  depends_on "KDE-mac/kde/kf5-syntax-highlighting"
  depends_on "libgit2"

  def install
    args = std_cmake_args
    args << "-DBUILD_TESTING=OFF"
    args << "-DBUILD_QCH=ON"
    args << "-DKDE_INSTALL_QMLDIR=lib/qt5/qml"
    args << "-DKDE_INSTALL_PLUGINDIR=lib/qt5/plugins"
    args << "-DKDE_INSTALL_QTPLUGINDIR=lib/qt5/plugins"

    mkdir "build" do
      system "cmake", "-G", "Ninja", "..", *args
      system "ninja"
      system "ninja", "install"
      prefix.install "install_manifest.txt"
    end
  end

  def caveats; <<~EOS
    You need to take some manual steps in order to make this formula work:
      "$(brew --repo kde-mac/kde)/tools/do-caveats.sh"
  EOS
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(KF5TesxtEditor REQUIRED)")
    system "cmake", ".", "-Wno-dev"
  end
end
