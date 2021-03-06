require 'set'
require 'pathname'

#
# The module that holds the awesomeness.
#
module AwesomeLoader
  #
  # Set up an AwesomeLoader::Autoloader instance.
  #
  #   AwesomeLoader.autoload root_depth: 2 do
  #     paths %w(app routes ** *.rb), root_depth: 1
  #     paths %w(app ** *.rb)
  #   end
  #
  # @param root_depth [Integer] Tells AwesomeLoader to start creating Modules for dirs *after* this level (default 2)
  # @param root_path [String] Path to root of the application (default Dir.pwd)
  # @param root_module [Module] Module to load your modules into (default Object). You'll probably always want to keep the default.
  # @param eager_load [Boolean] Make sure all files get loaded by the time the block finishes (default false)
  # @return [AwesomeLoader::Autoloader]
  #
  def self.autoload(root_depth: Autoloader::DEFAULT_ROOT_DEPTH, root_path: Dir.pwd, root_module: Object, eager_load: false, &block)
    autoloader = Autoloader.new(root_depth: root_depth, root_path: root_path, root_module: root_module, eager_load: eager_load)
    if block
      autoloader.instance_eval(&block)
      autoloader.finalize!
    end
    autoloader
  end

  #
  # The autoloader. Normally it's used indirectly through `AwesomeLoader.autoload`, but you can use it directly if you like:
  #
  #   AwesomeLoader::Autoloader.new(root_depth: 2).
  #     paths(['app', 'routes', '**', '*.rb'], root_depth: 1).
  #     paths(['app', '**', '*.rb']).
  #     finalize!
  #
  class Autoloader
    # The default root_dept for new instances
    DEFAULT_ROOT_DEPTH = 2

    # @return [Integer] root depth used for all paths unless otherwise specified
    attr_reader :default_root_depth
    # @return [Pathname] the application root
    attr_reader :root_path
    # @return [Module] the root ruby Module
    attr_reader :root_module
    # @return [Boolean] whether or not to automatically load all files once they're defined
    attr_reader :eager_load
    # @return [Set<String>] all defined files, ready to be eager_loaded
    attr_reader :all_files
    private :all_files

    #
    # Initialize a new AwesomeLoader::Autoloader.
    #
    # @param root_depth [Integer] Tells AwesomeLoader to start creating Modules for dirs *after* this level (default 2)
    # @param root_path [String] Path to root of the application (default Dir.pwd)
    # @param root_module [Module] Module to load your modules into (default Object). You'll probably always want to keep the default.
    # @param eager_load [Boolean] Make sure all files get loaded by the time the block finishes (default false)
    #
    def initialize(root_depth: DEFAULT_ROOT_DEPTH, root_path: Dir.pwd, root_module: Object, eager_load: false)
      @root_path, @root_module = Pathname.new(root_path.to_s), root_module
      @default_root_depth, @eager_load = root_depth, eager_load
      @all_files = Set.new
    end

    #
    # Set a glob pattern of files to be autoloaded.
    #
    #   autoloader.paths %w(app models ** *.rb)
    #
    # @param glob [Array<String>] A glob pattern as an array.
    # @paths root_depth [Integer] Depth at which to start creating modules for dirs. Defaults to whatever the AwesomeLoader::Autoloader instance was initialized with.
    # @return [AwesomeLoader::Autoloader] returns self, so you can chain calls
    #
    def paths(glob, root_depth: default_root_depth)
      builder = ModuleBuilder.new(root_depth: root_depth, root_module: root_module)
      blank_str = ''
      Dir.glob(File.join root_path.to_s, *glob).each do |full_path|
        next if all_files.include? full_path
        all_files << full_path

        rel_path = full_path.sub root_path.to_s, blank_str
        dir_path, file_name = File.split rel_path
        const_name = Utils.camelize file_name[0, file_name.size - 3]
        builder.module(dir_path).autoload const_name, full_path
      end
      self
    end

    #
    # Same as Ruby's built-in require, except that it accepts a blob and requires all matching files.
    # The require is immediate, the path is relative to the root_path, and no dir modules are created.
    #
    # @param glob [Array<String>] A glob pattern as an array.
    # @return [AwesomeLoader::Autoloader] returns self, so you can chain calls
    #
    def require(glob)
      Dir.glob(File.join root_path.to_s, *glob).each do |file|
        Kernel.require file
      end
      self
    end

    #
    # Perform any final operations or cleanup. If eager_load is true, this is where they're loaded.
    #
    def finalize!
      all_files.each { |f| Kernel.require f } if eager_load
      all_files.clear
      self
    end
  end
end
