# frozen_string_literal: true

require_relative "lib/autotrace/version"

Gem::Specification.new do |spec|
  spec.name = "autotrace"
  spec.version = Autotrace::VERSION
  spec.authors = ["Dylan Player"]
  spec.email = ["dylan@851.sh"]

  spec.summary = "Ruby bindings for the Autotrace library"
  spec.description = <<~DESC
    Ruby bindings for the Autotrace library, which converts raster images (like PNG)
    into vector graphics (like SVG). This gem provides a Ruby interface to the
    powerful Autotrace library, allowing for easy conversion of bitmap images to
    vector formats with extensive configuration options.
  DESC
  spec.homepage = "https://github.com/851-labs/autotrace"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/851-labs/autotrace"
  spec.metadata["changelog_uri"] = "https://github.com/851-labs/autotrace/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_runtime_dependency("ffi", "~> 1.17.1")
end
