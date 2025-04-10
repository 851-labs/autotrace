# frozen_string_literal: true

require "ffi"

module Autotrace
  # FFI module that provides bindings to the Autotrace C library.
  # This module handles all the low-level interactions with the C library
  # through FFI (Foreign Function Interface).
  module FFI
    extend ::FFI::Library

    ffi_lib_flags :now, :global

    ffi_lib [
      # libgobject (Linux, macOS, Windows)
      "libgobject-2.0", # generic name (might work if found via linker)
      "libgobject-2.0.so.0",       # typical on Linux distributions (Debian/RedHat)
      "libgobject-2.0.dylib",      # common on macOS (if installed via Homebrew or MacPorts)
      "gobject-2.0.dll" # common on Windows
    ]

    ffi_lib [
      # libglib
      "libglib-2.0",
      "libglib-2.0.so.0",
      "libglib-2.0.dylib",
      "glib-2.0.dll"
    ]

    ffi_lib [
      # ImageMagick's MagickCore library
      "libMagickCore-7.Q16HDRI",
      "libMagickCore-6.Q16HDRI",
      "libMagickCore-7.Q16.so",
      "libMagickCore-6.Q16.so.6",
      "libMagickCore-6.Q16.so"
    ]

    ffi_lib [
      # pstoedit library
      "libpstoedit",
      "libpstoedit.so.0",
      "libpstoedit.dylib",
      "pstoedit.dll"
    ]

    ffi_lib [
      # libpng library
      "libpng",
      "libpng16.so.16", # Often libpng is packaged as libpng16 on newer systems
      "libpng.dylib",
      "png.dll"
    ]

    # Load the main Autotrace library with alternate names:
    ffi_lib [
      "libautotrace.3",
      "libautotrace.so.3",  # Linux typical shared object name
      "libautotrace.dylib", # macOS typical dynamic library name
      "autotrace.dll"       # Windows DLL alternative
    ]

    # Module providing bindings to standard C library functions
    module CStdLib
      extend ::FFI::Library
      ffi_lib ::FFI::Library::LIBC

      attach_function :fopen, %i[string string], :pointer
      attach_function :fclose, [:pointer], :int
    end

    # Structure representing an RGB color in the Autotrace library
    class AtColor < ::FFI::Struct
      layout :r, :uint8, :g, :uint8, :b, :uint8
    end

    # Structure containing all the fitting options for the Autotrace algorithm
    class AtFittingOpts < ::FFI::Struct
      layout :background_color,         :pointer, # at_color*
             :charcode,                 :uint,
             :color_count,              :uint,
             :corner_always_threshold,  :float,
             :corner_surround,          :uint,
             :corner_threshold,         :float,
             :error_threshold,          :float,
             :filter_iterations,        :uint,
             :line_reversion_threshold, :float,
             :line_threshold,           :float,
             :remove_adjacent_corners,  :bool,
             :tangent_surround,         :uint,
             :despeckle_level,          :uint,
             :despeckle_tightness,      :float,
             :noise_removal,            :float,
             :centerline,               :bool,
             :preserve_width,           :bool,
             :width_weight_factor,      :float
    end

    # Structure containing output options for the Autotrace library
    class AtOutputOpts < ::FFI::Struct
      layout :dpi, :int
    end

    # Initialize the Autotrace library
    attach_function :autotrace_init, [], :void
    # Initialize input handlers
    attach_function :at_input_init, [], :int
    # Initialize modules
    attach_function :at_module_init, [], :int

    # Create and free fitting options
    attach_function :at_fitting_opts_new, [], :pointer
    attach_function :at_fitting_opts_free, [:pointer], :void

    # Create and free output options
    attach_function :at_output_opts_new, [], :pointer
    attach_function :at_output_opts_free, [:pointer], :void

    # Get input handler for a specific file
    attach_function :at_input_get_handler, [:string], :pointer
    # Read bitmap from file
    attach_function :at_bitmap_read, %i[pointer string pointer pointer pointer], :pointer

    # Create splines from bitmap
    attach_function :at_splines_new, %i[pointer pointer pointer pointer], :pointer
    # Write splines to output file
    attach_function :at_splines_write, %i[pointer pointer string pointer pointer pointer pointer], :void

    # Get output handler by file suffix
    attach_function :at_output_get_handler_by_suffix, [:string], :pointer

    # Free allocated memory
    attach_function :at_bitmap_free, [:pointer], :void
    attach_function :at_splines_free, [:pointer], :void
  end
end
