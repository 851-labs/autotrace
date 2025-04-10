#!/usr/bin/env ruby
# frozen_string_literal: true

puts "Ruby Version: #{RUBY_VERSION}"
puts "Load Path: #{$LOAD_PATH.join(":")}"
puts "Current Directory: #{Dir.pwd}"
puts "Files in /app/autotrace-gem/lib: #{Dir.glob("/app/autotrace-gem/lib/**/*")}"

begin
  puts "Attempting to require autotrace..."
  require "autotrace"
  puts "Successfully loaded autotrace!"
rescue LoadError => e
  puts "Error loading autotrace: #{e.message}"
  puts "Try loading from direct path..."
  require_relative "/app/autotrace-gem/lib/autotrace"
  puts "Successfully loaded autotrace from direct path!"
end

# This example demonstrates how to use the Autotrace gem to convert
# a raster image to a vector format with various options.

def trace_with_options(input_file, options = {})
  puts "Converting #{input_file} with options: #{options.inspect}"

  # Trace the image with the specified options
  result = Autotrace.trace_image(
    input_file,
    **options
  )

  puts "Conversion complete! Output file: #{result.path}"

  # Return the result file
  result
end

# Example 1: Simple conversion to SVG
puts "Example 1: Simple conversion to SVG"
trace_with_options("sample.png", output_suffix: "svg")

# Example 2: Conversion with custom options
puts "\nExample 2: Conversion with custom options"
trace_with_options("sample.png",
                   output_suffix: "svg",
                   background_color: "FFFFFF",  # White background
                   error_threshold: 1.0,        # Lower error threshold for more detail
                   despeckle_level: 2,          # Remove small artifacts
                   preserve_width: true,        # Preserve line widths
                   centerline: false,           # Don't trace along centerline
                   noise_removal: 0.95) # Remove noise while preserving detail

# Example 3: Convert to EPS format
puts "\nExample 3: Convert to EPS format"
trace_with_options("sample.png", output_suffix: "eps")

puts "\nAll conversions completed successfully!"
