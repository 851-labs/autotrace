# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "autotrace"
require "minitest/autorun"
require "fileutils"

# Initialize Autotrace for tests
Autotrace.init_autotrace

# Create test files directory if it doesn't exist
test_files_dir = File.expand_path("files", __dir__)
FileUtils.mkdir_p(test_files_dir) unless Dir.exist?(test_files_dir)

# Make sure test file location is valid
tower_file = File.join(test_files_dir, "tower.png")
unless File.exist?(tower_file)
  puts "Warning: Test image '#{tower_file}' not found"
  puts "Make sure to place the test image in the test/files directory"
end
