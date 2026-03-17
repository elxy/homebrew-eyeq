class Eyeq < Formula
  desc "Multi-video subjective quality comparison tool"
  homepage "https://github.com/elxy/eyeq"
  license "LGPL-2.1-or-later"
  version "0.1.0"

  on_macos do
    url "https://github.com/elxy/eyeq/releases/download/v#{version}/eyeq-v#{version}-macos-arm64.tar.gz"
    sha256 "PLACEHOLDER_MACOS"
  end

  on_linux do
    url "https://github.com/elxy/eyeq/releases/download/v#{version}/eyeq-v#{version}-linux-x86_64.tar.gz"
    sha256 "PLACEHOLDER_LINUX"
  end

  depends_on "ffmpeg"
  depends_on "libplacebo"
  depends_on "sdl3"
  depends_on "sdl3_ttf"
  depends_on "spdlog"

  on_macos do
    depends_on "molten-vk"
  end

  on_linux do
    depends_on "patchelf" => :build
  end

  def install
    bin.install "bin/eyeq"

    if OS.mac?
      # 将 bundled @executable_path/../lib/ 引用改为 Homebrew 管理的库
      libs = `otool -L #{bin}/eyeq`.lines[1..].map { |l| l.strip.split.first }
      libs.each do |lib_path|
        next unless lib_path.start_with?("@executable_path/../lib/")

        lib_name = File.basename(lib_path)
        real = Dir["#{HOMEBREW_PREFIX}/lib/#{lib_name}"].first
        real ||= Dir["#{HOMEBREW_PREFIX}/opt/*/lib/#{lib_name}"].first
        if real
          system "install_name_tool", "-change", lib_path, real, "#{bin}/eyeq"
        else
          opoo "Cannot find Homebrew library for #{lib_name}"
        end
      end
    else
      system "patchelf", "--set-rpath", "#{HOMEBREW_PREFIX}/lib", "#{bin}/eyeq"
    end
  end

  test do
    system bin/"eyeq", "--help"
  end
end
