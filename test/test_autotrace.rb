# frozen_string_literal: true

require "test_helper"
require "tempfile"

class TestAutotrace < Minitest::Test
  def test_convert_tower_to_svg
    image_path = File.expand_path("files/tower.png", __dir__)

    assert File.exist?(image_path), "Test image not found at #{image_path}"

    output = Tempfile.new(["tower", ".svg"])

    begin
      result = Autotrace.trace_image(
        image_path,
        output_suffix: "svg",
        output_file: output.path
      )

      assert_instance_of File, result
      assert_equal output.path, result.path
      assert File.exist?(result.path), "Output file should exist"
      assert File.size(result.path).positive?, "Output file should have content"

      result.close unless result.closed?
    ensure
      output.close
      output.unlink
    end
  end
end
