module TestHelpers
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
