FROM ruby:3.3.5-slim

# Install dependencies for Autotrace based on official build script
RUN apt-get update && apt-get install -y \
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
  pkg-config \
  curl \
  wget \
  && rm -rf /var/lib/apt/lists/*

# Clone and build Autotrace
WORKDIR /tmp
RUN git clone https://github.com/autotrace/autotrace.git && \
  cd autotrace && \
  ./autogen.sh && \
  ./configure --prefix=/usr && \
  make && \
  make install && \
  ldconfig && \
  cd .. && \
  rm -rf autotrace

# Set up working directory for the application
WORKDIR /app

# Create output directory
RUN mkdir -p /app/output

# Copy the entire gem source code to the container
COPY . /app/autotrace-gem/

# Install required dependencies for the gem
RUN gem install ffi -v "~> 1.17.1"

# Copy the example files to /app
COPY examples/trace_example.rb /app/trace_example.rb
COPY examples/run.sh /app/run.sh

# Make the run script executable
RUN chmod +x /app/run.sh

# Set RUBYLIB environment variable to include the autotrace gem lib directory
ENV RUBYLIB="/app/autotrace-gem/lib:${RUBYLIB}"

# Print information about the available libraries
RUN ldconfig -p | grep "libgobject\\|libglib\\|libMagickCore\\|libpstoedit\\|libpng"

# Set working directory back to /app
WORKDIR /app

# Find the locations of the required libraries for debugging
RUN echo "Checking for required libraries:" && \
  find /usr/lib -name "libautotrace*" && \
  find /usr/local/lib -name "libautotrace*" && \
  ldconfig -p | grep autotrace

# Verify that we can load the autotrace gem with better error handling
RUN ruby -e "begin; \
  require 'autotrace'; \
  puts 'Autotrace gem loaded successfully!'; \
  rescue LoadError => e; \
  puts \"LoadError: #{e.message}\"; \
  exit 1; \
  rescue => e; \
  puts \"Error: #{e.class.name} - #{e.message}\"; \
  puts e.backtrace; \
  exit 1; \
  end"

# Set the entry point to the shell script
ENTRYPOINT ["/app/run.sh"]

# The sample.png should be mounted from the host
# Example: docker run -v $(pwd)/examples/sample.png:/app/sample.png -v $(pwd)/output:/app/output autotrace-example
