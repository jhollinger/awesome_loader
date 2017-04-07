module AwesomeLoader
  #
  # Misc utilities.
  #
  module Utils
    # Regex to match "snake name" paths
    SNAKE = /_([a-z])/

    #
    # Converts a snake_case_name to a CamelCaseName.
    #
    # @param name [String] the snake_case version
    # @return [String] the CamelCase version
    #
    def self.camelize(name)
      name.capitalize.gsub(SNAKE) { |match| match[1].capitalize }
    end
  end
end
