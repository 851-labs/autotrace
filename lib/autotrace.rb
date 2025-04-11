# frozen_string_literal: true

require_relative "autotrace/version"
require_relative "autotrace/ffi"

# Autotrace is a Ruby gem that provides bindings to the Autotrace library,
# which converts raster images (like PNG) into vector graphics (like SVG).
#
# The library supports various input and output formats, and provides extensive
# configuration options for controlling the tracing process.
#
# @example Converting a PNG to SVG
#   Autotrace.trace_image("input.png", output_suffix: "svg")
#
# @example Converting with custom options
#   Autotrace.trace_image("input.png",
#     output_suffix: "svg",
#     background_color: "FFFFFF",
#     error_threshold: 1.0
#   )
module Autotrace
  # Base error class for all Autotrace-related errors
  class Error < StandardError; end

  class << self
    attr_accessor :initialized

    # Initialize the Autotrace library. This must be called before any other
    # operations. It sets up input handlers and other necessary components.
    #
    # @return [void]
    def init_autotrace
      return if initialized

      FFI.autotrace_init
      FFI.at_input_init
      FFI.at_module_init

      self.initialized = true
    end

    # Convert a raster image to a vector graphic format.
    #
    # @param input_image [String] Path to the input raster image
    #
    # @param output_suffix [String] Desired output format (e.g. "svg", "eps")
    # @param output_file [String, nil] Path to write the output file. If nil,
    #   the output file will be "<basename>.<output_suffix>" in the same folder
    #   as the input file.
    #
    # @param background_color [String, nil] Background color in hex format (e.g. "FFFFFF")
    # @param centerline [Boolean] Whether to trace along the centerline
    # @param charcode [Integer] Character code for text output
    # @param color_count [Integer] Number of colors to use
    # @param corner_always_threshold [Float] Threshold for corner detection
    # @param corner_surround [Integer] Number of points to consider for corner detection
    # @param corner_threshold [Float] Threshold for corner detection
    # @param despeckle_level [Integer] Level of despeckling to apply
    # @param despeckle_tightness [Float] Tightness of despeckling
    # @param dpi [Integer] DPI setting for output (affects MIF output scaling)
    # @param error_threshold [Float] Error threshold for curve fitting
    # @param filter_iterations [Integer] Number of filter iterations
    # @param line_reversion_threshold [Float] Threshold for line reversion
    # @param line_threshold [Float] Threshold for line detection
    # @param noise_removal [Float] Level of noise removal
    # @param preserve_width [Boolean] Whether to preserve line width
    # @param remove_adjacent_corners [Boolean] Whether to remove adjacent corners
    # @param tangent_surround [Integer] Number of points to consider for tangent detection
    # @param width_weight_factor [Float] Weight factor for width preservation
    #
    # @return [File] A File object pointing to the newly created vector file
    # @raise [Error] If any step in the conversion process fails
    def trace_image(
      input_image,
      output_suffix: "svg",
      output_file: nil,
      background_color: nil,
      centerline: false,
      charcode: 0,
      color_count: 0,
      corner_always_threshold: 60.0,
      corner_surround: 4,
      corner_threshold: 100.0,
      despeckle_level: 0,
      despeckle_tightness: 2.0,
      dpi: 0,
      error_threshold: 2.0,
      filter_iterations: 4,
      line_reversion_threshold: 0.01,
      line_threshold: 1.0,
      noise_removal: 0.99,
      preserve_width: false,
      remove_adjacent_corners: false,
      tangent_surround: 3,
      width_weight_factor: 0.0
    )
      init_autotrace

      # 1. Create the input & output option structs
      fitting_opts_ptr = FFI.at_fitting_opts_new
      raise Error, "Failed to allocate fitting options" if fitting_opts_ptr.null?

      output_opts_ptr = FFI.at_output_opts_new
      raise Error, "Failed to allocate output options" if output_opts_ptr.null?

      # 2. Fill in all the fields from your arguments.
      configure_fitting_opts(
        fitting_opts_ptr,
        background_color: background_color,
        centerline: centerline,
        charcode: charcode,
        color_count: color_count,
        corner_always_threshold: corner_always_threshold,
        corner_surround: corner_surround,
        corner_threshold: corner_threshold,
        despeckle_level: despeckle_level,
        despeckle_tightness: despeckle_tightness,
        error_threshold: error_threshold,
        filter_iterations: filter_iterations,
        line_reversion_threshold: line_reversion_threshold,
        line_threshold: line_threshold,
        noise_removal: noise_removal,
        preserve_width: preserve_width,
        remove_adjacent_corners: remove_adjacent_corners,
        tangent_surround: tangent_surround,
        width_weight_factor: width_weight_factor
      )

      configure_output_opts(output_opts_ptr, dpi: dpi)

      # 3. Acquire input handler & read the bitmap
      input_handler = FFI.at_input_get_handler(input_image)
      raise Error, "Failed to get input handler for #{input_image}" if input_handler.null?

      bitmap = FFI.at_bitmap_read(input_handler, input_image, nil, nil, nil)
      raise Error, "Failed to read bitmap from #{input_image}" if bitmap.null?

      # 4. Create splines
      splines = FFI.at_splines_new(bitmap, fitting_opts_ptr, nil, nil)
      raise Error, "Failed to create splines" if splines.null?

      # 5. Output handler
      output_handler = FFI.at_output_get_handler_by_suffix(output_suffix)
      raise Error, "Unknown output format: .#{output_suffix}" if output_handler.null?

      # 6. Determine output file path
      if output_file.nil? || output_file.empty?
        # default to "<basename>.<suffix>"
        output_basename = File.basename(input_image, ".*")
        output_file = "#{output_basename}.#{output_suffix}"
      end

      # 7. Write to a real file
      c_file = FFI::CStdLib.fopen(output_file, "wb")
      raise Error, "Failed to open #{output_file} with C fopen" if c_file.null?

      FFI.at_splines_write(
        output_handler,
        c_file,
        output_file,
        output_opts_ptr,
        splines,
        nil, # msg_func
        nil  # msg_data
      )

      # Close
      FFI::CStdLib.fclose(c_file)

      File.open(output_file, "rb")
    end

    private

    # Convert a background color hex string (e.g. "FF00FF") into an at_color struct pointer
    # or return nil if background_color is not specified.
    def parse_background_color(background_color)
      return nil if background_color.nil? || background_color.empty?

      # Convert e.g. "FFFFFF" => r=255,g=255,b=255
      rgb = background_color.strip
      rgb = rgb.delete_prefix("#") # remove leading '#' if present
      raise Error, "Background color must be 6 hex digits" unless rgb.size == 6

      r = rgb[0..1].to_i(16)
      g = rgb[2..3].to_i(16)
      b = rgb[4..5].to_i(16)

      # Allocate an AtColor struct in memory
      color_ptr = ::FFI::MemoryPointer.new(:uint8, 3)
      color_struct = FFI::AtColor.new(color_ptr)
      color_struct[:r] = r
      color_struct[:g] = g
      color_struct[:b] = b
      color_ptr
    end

    # Fill in at_fitting_opts_type
    def configure_fitting_opts(
      fitting_opts_ptr,
      background_color: nil,
      centerline: false,
      charcode: 0,
      color_count: 0,
      corner_always_threshold: 60.0,
      corner_surround: 4,
      corner_threshold: 100.0,
      despeckle_level: 0,
      despeckle_tightness: 2.0,
      error_threshold: 2.0,
      filter_iterations: 4,
      line_reversion_threshold: 0.01,
      line_threshold: 1.0,
      noise_removal: 0.99,
      preserve_width: false,
      remove_adjacent_corners: false,
      tangent_surround: 3,
      width_weight_factor: 0.0
    )
      opts = FFI::AtFittingOpts.new(fitting_opts_ptr)

      # Possibly parse background color
      bg_ptr = parse_background_color(background_color)
      opts[:background_color]          = bg_ptr
      opts[:charcode]                  = charcode
      opts[:color_count]               = color_count
      opts[:corner_always_threshold]   = corner_always_threshold
      opts[:corner_surround]           = corner_surround
      opts[:corner_threshold]          = corner_threshold
      opts[:despeckle_level]           = despeckle_level
      opts[:despeckle_tightness]       = despeckle_tightness
      opts[:error_threshold]           = error_threshold
      opts[:filter_iterations]         = filter_iterations
      opts[:line_reversion_threshold]  = line_reversion_threshold
      opts[:line_threshold]            = line_threshold
      opts[:noise_removal]             = noise_removal
      opts[:preserve_width]            = preserve_width
      opts[:remove_adjacent_corners]   = remove_adjacent_corners
      opts[:tangent_surround]          = tangent_surround
      opts[:width_weight_factor]       = width_weight_factor
      opts[:centerline]                = centerline

      fitting_opts_ptr
    end

    # Fill in at_output_opts_type (currently only 'dpi')
    def configure_output_opts(output_opts_ptr, dpi: 0)
      out = FFI::AtOutputOpts.new(output_opts_ptr)
      out[:dpi] = dpi
      output_opts_ptr
    end
  end
end
