require 'set'

module AwesomeLoader
  def self.autoload(root_depth:, root: Dir.cwd, eager_load: false, &block)
    autoloader = Autoloader.new(root: root, root_depth: root_depth, eager_load: eager_load)
    if block
      autoloader.instance_eval(&block)
      autoloader.finialize
    end
    autoloader
  end

  class Autoloader
    RB_EXT = /\.rb$/

    attr_reader :root
    attr_reader :default_root_depth
    attr_reader :eager_load
    attr_reader :all_files

    def initialize(root_depth:, root: Dir.cwd, eager_load: false)
      @root = Pathname.new(root.to_s)
      @default_root_depth, @eager_load = root_depth, eager_load
      @all_files = []
    end

    def paths(array, root_depth: default_root_depth)
      files = Dir.glob File.join *array
      root_regex = Regexp.new "^#{File.join *array[0, root_depth]}/?"

      # Get an array of nested dirs (parent dir always comes before child dir)
      nested_dirs = files.
        map { |path| File.dirname(path).sub(root_regex, '') }.uniq.
        reduce(Set.new) { |dirs, leaf_dir|
          dirs + leaf_dir.split('/').reduce([]) { |a, dir|
            a << File.join(*a, dir)
          }
        }

      # Create modules for each dir. Set a Hash of dir path => Module.
      modules = nested_dirs.reduce({'.' => Object}) { |a, dir|
        parent_module = a.fetch File.dirname dir
        new_module = parent_module.const_set Utils.camelize(File.basename dir), Module.new
        a[dir] = new_module
        a
      }

      # For each file, look up it's dir module and set autoload on the class/module in the file.
      files.each do |full_path|
        rel_dir = File.dirname full_path.sub(root_regex, '')
        abs_path = self.root.join(full_path)
        file_const_name = Utils.camelize File.basename(full_path).sub(RB_EXT, '')
        mod = modules.fetch rel_dir
        mod.autoload file_const_name, abs_path
        self.all_files << abs_path if eager_load
      end

      self
    end

    def finialize
      all_files.each { |f| require f } if eager_load
      all_files.clear
      self
    end
  end
end
