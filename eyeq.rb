class Eyeq < Formula
  desc "Multi-video subjective quality comparison tool"
  homepage "https://github.com/elxy/eyeq"
  license "LGPL-2.1-or-later"
  version "0.0.3"

  on_macos do
    url "https://github.com/elxy/eyeq/releases/download/v#{version}/eyeq-v#{version}-macos-arm64.tar.gz"
    sha256 "a53d9cc0c023facd3dc70a6b819f8ced6780e017cae14687dcfa9405419089da"
  end

  on_linux do
    url "https://github.com/elxy/eyeq/releases/download/v#{version}/eyeq-v#{version}-linux-x86_64.tar.gz"
    sha256 "33ba2f26a46696498cd4ffacac78255a0288ff11da9c57cb895181e4b489a01a"
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

      # install_name_tool 修改库路径后原有签名失效，需要 ad-hoc 重签名
      system "codesign", "--force", "--sign", "-", "#{bin}/eyeq"
    else
      system "patchelf", "--set-rpath", "#{HOMEBREW_PREFIX}/lib", "#{bin}/eyeq"
    end
  end

  test do
    system bin/"eyeq", "--help"
  end
end
