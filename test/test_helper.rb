require 'awesome_loader'
require 'minitest/autorun'

module TestHelpers
  #
  # Create an application in a temporary dir. Pass a block and do your think in it.
  # After the block the dirs and files will be deleted.
  #
  # @param files [Hash] {rel_file_path => contents}
  #
  def tmp_app(files)
    Dir.mktmpdir do |tmpdir|
      files.each do |path, content|
        FileUtils.mkdir_p File.join(tmpdir, File.dirname(path))
        File.write File.join(tmpdir, path), content
      end
      yield tmpdir
    end
  end
end
