module AwesomeLoader
  #
  # Misc utilities.
  #
  module Utils
    # Regex to match "snake name" paths
    SNAKE = %r{_([a-z])}
    LEADING_SEP = %r{^/}
    TRAILING_SEP = %r{/$}

    #
    # Converts a snake_case_name to a CamelCaseName.
    #
    # @param name [String] the snake_case version
    # @return [String] the CamelCase version
    #
    def self.camelize(name)
      name.capitalize.gsub(SNAKE) { |match| match[1].capitalize }
    end

    #
    # Returns the path with any leading or trailing /'s removed.
    #
    # @param path [String]
    # @return [String]
    #
    def self.clean_path(path)
      path.sub(LEADING_SEP, '').sub(TRAILING_SEP, '')
    end
  end
end
