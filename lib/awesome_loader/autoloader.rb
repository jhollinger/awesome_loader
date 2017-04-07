require 'set'
require 'pathname'

#
# A module that holds all the awesomeness.
#
module AwesomeLoader
  #
  # Set up an AwesomeLoader::Autoloader instance.
  #
  #   AwesomeLoader.autoload root_depth: 2 do
  #     paths %w(app models ** *.rb)
  #     paths %w(app helpers ** *.rb)
  #     paths %w(app routes ** *.rb), root_depth: 1
  #   end
  #
  # @param root_depth [String] Tells AwesomeLoader to start creating Modules for dirs *after* this level
  # @param root [String] Path to root of the application (default Dir.cwd)
  # @param eager_load [Boolean] Make sure all files get loaded by the time the block finishes (default false)
  # @return [AwesomeLoader::Autoloader]
  #
  def self.autoload(root_depth:, root: Dir.cwd, eager_load: false, &block)
    autoloader = Autoloader.new(root: root, root_depth: root_depth, eager_load: eager_load)
    if block
      autoloader.instance_eval(&block)
      autoloader.finialize!
    end
    autoloader
  end

  #
  # The autoloader. Normally it's used indirectly through AwesomeLoader.autoload, but you can use it directly if you like:
  #
  #   AwesomeLoader::Autoloader.new(root_depth: 2).
  #     paths(%w(app models ** *.rb)).
  #     paths(%w(app helpers *.rb)).
  #     paths(%w(app routes ** *.rb), root_depth: 1).
  #     finialize!
  #
  class Autoloader
    RB_EXT = /\.rb$/

    # @return [Pathname] the application root
    attr_reader :root
    # @return [Integer] root depth used for all paths unless otherwise specified
    attr_reader :default_root_depth
    # @return [Boolean] whether or not to automatically load all files once they're defined
    attr_reader :eager_load
    # @return [Array<String>] all defined files, ready to be eager_loaded
    attr_reader :all_files
    private :all_files

    #
    # Initialize a new AwesomeLoader::Autoloader.
    #
    # @param root_depth [String] Tells AwesomeLoader to start creating Modules for dirs *after* this level
    # @param root [String] Path to root of the application (default Dir.cwd)
    # @param eager_load [Boolean] Make sure all files get loaded by the time the block finishes (default false)
    #
    def initialize(root_depth:, root: Dir.cwd, eager_load: false)
      @root = Pathname.new(root.to_s)
      @default_root_depth, @eager_load = root_depth, eager_load
      @all_files = []
    end

    #
    # Set a glob pattern of files to be autoloaded.
    #
    #   autoloader.paths %w(app models ** *.rb)
    #
    # @param array [Array<String>] A glob pattern as an array.
    # @paths root_depth [Integer] Depth at which to start creating modules for dirs. Defaults to whatever the AwesomeLoader::Autoloader instance was initialized with.
    # @return [AwesomeLoader::Autoloader] returns self, so you can chain calls
    #
    def paths(array, root_depth: default_root_depth)
      files = Dir.glob File.join *array
      root_regex = Regexp.new "^([^/]+/){%d}" % root_depth

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
      files.each do |path|
        full_path = self.root.join(path)
        const_name = Utils.camelize File.basename(path).sub(RB_EXT, '')
        mod = modules.fetch File.dirname path.sub(root_regex, '')
        mod.autoload const_name, full_path
        all_files << full_path if eager_load
      end

      self
    end

    #
    # Perform any final operations or cleanup. If eager_load is true, this is where they're loaded.
    #
    def finialize!
      all_files.each { |f| require f } if eager_load
      all_files.clear
      self
    end
  end
end
