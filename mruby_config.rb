MRuby::Build.new do |conf|
  toolchain :gcc
  conf.gem :github => "mobiruby/mruby-cfunc", :checksum_hash => "c27a12d1828de0ed4e428ca8f4aad26e1f85369b" do |g|
    
  end
  conf.gem :github => "pbosetti/mruby-merb", :checksum_hash => "3a7ae850a5986369612de282e5748c3528d23d9c"
  conf.gem :github => "mobiruby/mruby-cocoa", :checksum_hash => "baa8c639f77d0b33fe6351046e20fd02535fd2ef"
  conf.gembox 'default'
end
