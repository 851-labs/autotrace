# Autotrace Examples

This directory contains examples demonstrating how to use the Autotrace gem.

## Contents

- `Dockerfile` - Docker setup for running Autotrace
- `trace_example.rb` - Example Ruby script showing various tracing options
- `sample.png` - Sample image for the examples

## Running with Docker

The provided Dockerfile sets up a complete environment for running Autotrace.

### Build the Docker image

```bash
docker build -t autotrace-example -f examples/Dockerfile .
```

### Run the container with the sample image

```bash
# Create a directory to store output files
mkdir -p output

# Run the container with the sample image mounted
docker run -v $(pwd)/examples/sample.png:/app/sample.png -v $(pwd)/output:/app/output autotrace-example
```

### Using your own images

You can convert your own images by mounting them to the container:

```bash
docker run -v /path/to/your/image.png:/app/sample.png -v $(pwd)/output:/app/output autotrace-example
```

## Running the Ruby Example Directly

If you have Autotrace installed on your system, you can run the example script directly:

```bash
cd examples
ruby trace_example.rb
```

Make sure you have the `sample.png` file in the same directory as the script.

## Output

The traced vector files will be created in the same directory as the input file, with the appropriate extension:

- `sample.svg` - SVG vector output
- `sample.eps` - EPS vector output (if you run Example 3)

## Additional Resources

For more information about Autotrace and its options, see:

- [Autotrace GitHub Repository](https://github.com/autotrace/autotrace)
- [Ruby Gem Documentation](https://github.com/851-labs/autotrace)
