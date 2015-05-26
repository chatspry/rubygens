XCODE_ROOT=%x[xcode-select -print-path].strip
SDK_ROOT=Dir["#{XCODE_ROOT}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.1*.sdk/"].sort.last
FFI_DIR="/usr/local/opt/libffi/lib"
FFI_INCLUDE_DIR=Dir["#{FFI_DIR}/libffi-*/include"].sort.last

MRuby::Build.new do |conf|
  toolchain :clang
  conf.gem 'External/mruby-cfunc' do |g|
    g.cc.include_paths << FFI_INCLUDE_DIR
  end
  conf.gem 'External/mruby-cocoa' do |g|
    g.cc.include_paths << FFI_INCLUDE_DIR
    g.objc.include_paths << FFI_INCLUDE_DIR
  end
  conf.gem :github => "pbosetti/mruby-merb", :checksum_hash => "3a7ae850a5986369612de282e5748c3528d23d9c"
  conf.gembox 'default'

  enable_debug

  [conf.cc, conf.objc].each do |cc|
    cc.command = 'xcrun'
    cc.defines = %w(ENABLE_DEBUG)
    cc.flags = %W(-sdk macosx clang -isysroot #{SDK_ROOT} -O0 -g -Wall -Werror-implicit-function-declaration)
  end

  conf.linker do |l|
    l.command = 'xcrun'
    l.flags = %W(-sdk macosx clang -isysroot #{SDK_ROOT} -L#{FFI_DIR})
  end

  conf.archiver do |ar|
    ar.command = 'xcrun'
    ar.archive_options = 'libtool -static -o %{outfile} %{objs}'
  end
end

# Aliases for Xcode
task :build => :all
task :install => :all
task :installhdrs => :all
task :installsrc => :all
