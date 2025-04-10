#!/bin/bash

echo "==================================================="
echo "Autotrace - Converting raster images to vector graphics"
echo "==================================================="

if [ ! -f /app/sample.png ]; then
  echo "Error: sample.png not found in /app directory."
  echo "Please mount your image to /app/sample.png:"
  echo "  docker run -v /path/to/your/image.png:/app/sample.png autotrace-example"
  exit 1
fi

echo "Found image: /app/sample.png"
echo "Running trace script..."
echo "==================================================="

# Run the Ruby example script
ruby /app/trace_example.rb

# Copy output files to output directory
cp /app/*.svg /app/output/ 2>/dev/null || true
cp /app/*.eps /app/output/ 2>/dev/null || true

echo "==================================================="
echo "Process complete!"
echo "Output files can be found in the mounted output directory"
echo "===================================================" 