# 🎨 Autotrace

Ruby bindings for the Autotrace library, which converts raster images (like PNG) into vector graphics (like SVG). This gem provides a Ruby interface to the powerful Autotrace library, allowing for easy conversion of bitmap images to vector formats with extensive configuration options.

## 📦 Installation

### Prerequisites

Before installing the gem, you need to install the Autotrace library and its dependencies on your system.

#### 🍎 macOS

```bash
brew install libffi
brew install autotrace
```

#### 🐧 Ubuntu

Since Autotrace is not available in the default Ubuntu repositories, you'll need to compile it from source:

```bash
# Install dependencies
sudo apt update
sudo apt install -y \
  build-essential \
  git \
  libmagickcore-dev \
  autotools-dev \
  autopoint \
  diffutils \
  libtool \
  intltool \
  libpng-dev \
  libexif-dev \
  libtiff5-dev \
  libjpeg-dev \
  libxml2-dev \
  libbz2-dev \
  libpstoedit-dev \
  libfreetype6-dev \
  libpstoedit0c2a \
  libbz2-1.0 \
  libgd3 \
  libffi-dev \
  pkg-config

# Clone the repository
git clone https://github.com/autotrace/autotrace.git
cd autotrace

# Generate configuration files
./autogen.sh

# Configure and build
./configure --prefix=/usr
make

# Test if it works before installing
./autotrace --version

# Install and update the shared library cache
sudo make install
sudo ldconfig
```

**Note:** If you encounter issues with ImageMagick or Pstoedit during compilation, you can disable them with configuration options:

- `./configure --without-magick` - Disable ImageMagick support
- `./configure --without-pstoedit` - Disable Pstoedit support

For more detailed installation instructions and troubleshooting, refer to the [official Autotrace installation guide](https://github.com/autotrace/autotrace/blob/master/INSTALL.md).

#### 🐳 Using Docker

There is a reference Dockerfile here: [examples/Dockerfile](examples/Dockerfile).

```bash
# Build the Docker image
docker build -t autotrace-example -f examples/Dockerfile .

# Create a directory to store output files
mkdir -p output

# Run the container with your image
docker run -v /path/to/your/image.png:/app/sample.png -v $(pwd)/output:/app/output autotrace-example
```

### 💎 Installing the Gem

Add this line to your application's Gemfile:

```ruby
gem 'autotrace'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install autotrace
```

## 🚀 Usage

### Basic Usage

Convert a PNG image to SVG:

```ruby
require 'autotrace'

# Convert image.png to image.svg
Autotrace.trace_image('image.png', output_suffix: 'svg')
```

### Advanced Usage

The library provides extensive configuration options for controlling the tracing process:

```ruby
require 'autotrace'

# Convert with custom options
Autotrace.trace_image('input.png',
  output_suffix: 'svg',
  background_color: 'FFFFFF',  # White background
  error_threshold: 1.0,        # Lower error threshold for more detail
  despeckle_level: 2,          # Remove small artifacts
  preserve_width: true,        # Preserve line widths
  centerline: false,           # Don't trace along centerline
  noise_removal: 0.95,         # Remove noise while preserving detail
  color_count: 8              # Limit to 8 colors
)
```

### ⚙️ Available Options

The following options are available for fine-tuning the conversion process:

- `background_color`: Background color in hex format (e.g. "FFFFFF")
- `centerline`: Whether to trace along the centerline (boolean)
- `charcode`: Character code for text output (integer)
- `color_count`: Number of colors to use (integer)
- `corner_always_threshold`: Threshold for corner detection (float)
- `corner_surround`: Number of points to consider for corner detection (integer)
- `corner_threshold`: Threshold for corner detection (float)
- `despeckle_level`: Level of despeckling to apply (integer)
- `despeckle_tightness`: Tightness of despeckling (float)
- `dpi`: DPI setting for output (affects MIF output scaling) (integer)
- `error_threshold`: Error threshold for curve fitting (float)
- `filter_iterations`: Number of filter iterations (integer)
- `line_reversion_threshold`: Threshold for line reversion (float)
- `line_threshold`: Threshold for line detection (float)
- `noise_removal`: Level of noise removal (float)
- `preserve_width`: Whether to preserve line width (boolean)
- `remove_adjacent_corners`: Whether to remove adjacent corners (boolean)
- `tangent_surround`: Number of points to consider for tangent detection (integer)
- `width_weight_factor`: Weight factor for width preservation (float)

## 🔧 Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### 🚀 Creating a Release

This project uses GitHub Actions to automate the release process. To create a new release:

1. Update the version number in `lib/autotrace/version.rb`
2. Update the `CHANGELOG.md` with the changes for the new version
3. Commit your changes:
   ```bash
   git add lib/autotrace/version.rb CHANGELOG.md
   git commit -m "Bump version to vX.Y.Z"
   ```
4. Create and push a new tag:
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   git push origin vX.Y.Z
   ```

The GitHub Actions workflow will automatically:

- Run the test suite
- Build the gem
- Publish the gem to RubyGems.org

**Note:** Make sure you have set up the `RUBYGEMS_API_KEY` secret in your GitHub repository settings before creating a release. You can generate an API key from your RubyGems account settings.

## 🧪 Testing

The gem includes a test suite that verifies the basic functionality works correctly.

### Prerequisites for Testing

1. Make sure you have the Autotrace C library installed (see Installation section above)
2. Place a test image named `tower.png` in the `test/files` directory

### Running the Tests

You can run the tests with:

```bash
# Run all tests
rake test

# Run a specific test file
ruby -I lib:test test/test_autotrace.rb
```

The test suite includes a basic test that converts a PNG image to SVG format to ensure the gem is working correctly with your system's Autotrace installation.

### Troubleshooting Tests

If you encounter errors during testing:

1. Verify that Autotrace is correctly installed on your system by running `autotrace --version` in your terminal
2. Check that the test image file exists at `test/files/tower.png`
3. Look for any warning messages about unsupported or missing libraries

## 🤝 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/851-labs/autotrace. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/851-labs/autotrace/blob/main/CODE_OF_CONDUCT.md).

## 📄 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## ✨ Code of Conduct

Everyone interacting in the Autotrace project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/851-labs/autotrace/blob/main/CODE_OF_CONDUCT.md).
