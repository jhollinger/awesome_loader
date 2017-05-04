module AwesomeLoader
  #
  # Recursively builds modules out of directory structures.
  #
  class ModuleBuilder
    # @return [Integer] the dir depth at which to start building modules.
    attr_reader :root_depth
    # @return [Module] the root ruby Module
    attr_reader :root_module

    #
    # Initializes a new builder.
    #
    # @param root_depth [Integer] directory depth at which to start building modules.
    # @param root_module [Module] Module to load the modules into (default Object). You'll probably always want to keep the default.
    #
    def initialize(root_depth:, root_module: Object)
      @root_depth = root_depth
      @root_module = root_module
    end

    #
    # Returns (recursively creating if necessary) the Module represented by the dir path. The path should be relative
    # to your application root/working directory. Directories are expected to use snake case, and the Modules will
    # use camel case.
    #
    #   # Since root_depth is 2, the first 2 dirs in any path will be ignored
    #   builder = ModuleBuilder.new(root_depth: 2)
    #
    #   builder.module('src/models')
    #   => Object
    #
    #   builder.module('src/features/billing')
    #   => Billing
    #
    #   builder.module('src/services/billing/foo')
    #   => Billing::Foo
    #
    # @param rel_filepath [String] The path, relative to your application root, to the file you want the module for.
    # @return [Module] The module
    #
    def module(rel_path)
      module_names(rel_path).reduce(root_module) { |parent_mod, mod_name|
        if parent_mod.const_defined? mod_name, false
          parent_mod.const_get mod_name 
        else
          parent_mod.const_set mod_name, Module.new
        end
      }
    end

    #
    # Returns an array of nested Module names based on the directory structure of the given path.
    #
    #   builder = ModuleBuilder.new(root_depth: 2)
    #
    #   # Since root_depth is 2, 'src' and 'models' are ignored and there aren't any modules
    #   builder.nested_dirs('src/models')
    #   => []
    #
    #   builder.nested_dirs('src/features/billing')
    #   => ['Billing']
    #
    #   builder.nested_dirs('src/features/billing/foo')
    #   => ['Billing', 'Foo']
    #
    # @param rel_filepath [String] The path, relative to your application root, to the file you want the module for.
    # @return [Array<String>] Array of nested Module names
    #
    def module_names(rel_path)
      dir_names = Utils.clean_path(rel_path).split '/'
      return [] if rel_path == '.' or root_depth > dir_names.size
      dir_names[root_depth..-1].map { |name| Utils.camelize name }
    end
  end
end
