module AwesomeLoader
  module Utils
    SNAKE = /_([a-z])/

    def self.camelize(name)
      name.capitalize.gsub(SNAKE) { |match| match[1].capitalize }
    end
  end
end
