require 'formula'

class Dart < Formula
  homepage 'https://www.dartlang.org/'

  version '1.16.0'
  if MacOS.prefer_64_bit?
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.16.0/sdk/dartsdk-macos-x64-release.zip'
    sha256 'a6a23a8568a6547f2c3f6c7e40e2e692cb3c3010337436617f29398fa57ff4a0'
  else
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.16.0/sdk/dartsdk-macos-ia32-release.zip'
    sha256 'c8c38c699791d01a7b682929b9d8a94399aa3ae50561092ae5856454b73f1e4b'
  end

  option 'with-content-shell', 'Download and install content_shell -- headless Dartium for testing'
  option 'with-dartium', 'Download and install Dartium -- Chromium with Dart'

  devel do
    version '1.17.0-dev.2.0'
    if MacOS.prefer_64_bit?
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.17.0-dev.2.0/sdk/dartsdk-macos-x64-release.zip'
      sha256 '3a62fe477664f689d6dce9cc99450d3212b6f4f89c1e25d3d8e84b201ed860f1'
    else
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.17.0-dev.2.0/sdk/dartsdk-macos-ia32-release.zip'
      sha256 'd8cf9354dbed4e1f587f4128167db3f8e9a6f10f8e52905764791fdf3e615380'
    end

    resource 'content_shell' do
      version '1.17.0-dev.2.0'
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.17.0-dev.2.0/dartium/content_shell-macos-ia32-release.zip'
      sha256 '6e1522aae7e6772bf68f5d119d5e904a0687044a06913db06a3333088b3b523c'
    end

    resource 'dartium' do
      version '1.17.0-dev.2.0'
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.17.0-dev.2.0/dartium/dartium-macos-ia32-release.zip'
      sha256 '6d72bfbd65befe795780678b2de7c8b13778da0abd2ca3c5431169387f58fa51'
    end
  end

  resource 'content_shell' do
    version '1.16.0'
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.16.0/dartium/content_shell-macos-ia32-release.zip'
    sha256 '70b1f9ed77b8a9d5ff2e2253e20b687dcdd581bca594059cb19fb3c2ff749bea'
  end

  resource 'dartium' do
    version '1.16.0'
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.16.0/dartium/dartium-macos-ia32-release.zip'
    sha256 '8efe2fb0db7a90e4e3848d09f817ac23e47394c5514029b7db7aaba33dd6e1bf'
  end

  def install
    libexec.install Dir['*']
    bin.install_symlink "#{libexec}/bin/dart"
    bin.write_exec_script Dir["#{libexec}/bin/{pub,dart?*}"]

    if build.with? 'dartium'
      dartium_binary = 'Chromium.app/Contents/MacOS/Chromium'
      prefix.install resource('dartium')
      (bin+"dartium").write shim_script dartium_binary
    end

    if build.with? 'content-shell'
      content_shell_binary = 'Content Shell.app/Contents/MacOS/Content Shell'
      prefix.install resource('content_shell')
      (bin+"content_shell").write shim_script content_shell_binary
    end
  end

  def shim_script target
    <<-EOS.undent
      #!/usr/bin/env bash
      exec "#{prefix}/#{target}" "$@"
    EOS
  end

  def caveats; <<-EOS.undent
    Please note the path to the Dart SDK:
      #{opt_libexec}

    --with-dartium:
      To use with IntelliJ, set the Dartium execute home to:
        #{opt_prefix}/Chromium.app
    EOS
  end

  test do
    (testpath/'sample.dart').write <<-EOS.undent
      void main() {
        print(r"test message");
      }
    EOS

    assert_equal "test message\n", shell_output("#{bin}/dart sample.dart")
  end
end
