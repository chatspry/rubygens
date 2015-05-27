RubyGens - An mruby-based code generator
----------------------------------------

Neither Swift or Objective-C support annotations at the compiler-level, which in
languages like Java and C# are used by developers to generate some boilerplate
for the compiler. This greatly reduces the amount of trivial boilerplate code
that has to be written by the developer.

One particularly obnoxious bit of boilerplate on the Apple stack is the creation
of classes that correspond to your Core Data model. Even if you're not using
Core Data, there's likely a lot of boilerplate that you either copy across model
files or copy and make small tweaks to.

The solution to this is normally [Mogenerator][Mogen], and that should
definitely be your first port of call. Mogenerator's been battle tested and used
in enterprise-scale production apps before, and if it does everything you need,
you should keep using it.

That said, this project aims to exceed Mogenerator in the following ways:

1. It will not get bogged down by backwards compatibility concerns.
   * Mogenerator still targets Mac OS X 10.6, an operating system released more
     than 5 years ago.
   * The Mogenerator source code relies on several unmaintained dependencies,
     and as a result is not written in Modern Objective-C or Automatic Reference
     Counting. This makes community contributions difficult.
   * RubyGens will always require the same OS X that the latest Xcode does.
2. It will use a modern templating engine which also embeds a complete scripting
   language.
   * This engine is [mruby-merb] and the scripting language is [mruby].
   * This should encourage users to write their own templates, just using the
     provided one as a base.
   * Ruby is a very common and friendly scripting language, and has a thriving
     community online. Compare this to Mogenerator's positively ancient
     template system [MiscMergeKit].
3. It will put more customisation options in the hands of template writers and
   users without the need to submit patches to RubyGens, such as determining
   what the output files are.

[Mogen]: https://github.com/rentzsch/mogenerator
[mruby-merb]: https://github.com/pbosetti/mruby-merb
[mruby]: https://github.com/mruby/mruby
[MiscMergeKit]: https://www.google.com/search?q=MiscMergeKit

Installing
----------

Install [Homebrew].

```sh
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install libFFI. Sorry, the one that ships with Xcode is too old.

```sh
brew install libffi
```

Clone repo with submodules.

```sh
git clone --recursive https://github.com/chatspry/rubygens.git
```

The app should now compile in Xcode. Use the workspace, not the xcodeproj, since
this project uses CocoaPods.

```sh
cd rubygens
open RubyGens.xcworkspace
```

[Homebrew]: http://brew.sh/
