# awesome_loader

An awesome way to load your (non-Rails) Ruby application! Tired of tons of manual requires? Me too! So I made this little gem to augment Ruby's built-in `autoload` functionality. Works pretty much the same as in Rails. (NOTE Don't confuse this with auto-**re**loading.)

## Install

Just add to your Gemfile.

    gem 'awesome_loader'

## Basic Usage

Let's say your (non-Rails) app has a very Rails-like layout. `app/models`, `app/helpers`, etc. And those might have some subdirectories that correspond to module names. This is all you have to do:

    # The root_depth argument is saying "Start creating modules for dirs after the first 2 levels"
    AwesomeLoader.autoload root_depth: 2 do
      paths %w(app ** *.rb)
    end

## Advanced Usage

Maybe your app structure is more complicated. That's fine too.

    AwesomeLoader.autoload root_depth: 2 do
      # These first few work just like above
      paths %w(app models ** *.rb)
      paths %w(app helpers ** *.rb)

      # But the files in these dirs have top-level Routes and Entities modules
      paths %w(app routes ** *.rb), root_depth: 1
      paths %w(app entities ** *.rb), root_depth: 1
    end

## Eager Loading

If you're running a threaded server like Puma or Thin, it's often considered best practice to load everything
up-front, instead of possibly loading something during a request Thread. At least in production.

    AwesomeLoader.autoload root_depth: 2, eager_load: true do
      ...
    end

## License

MIT License. See LICENSE for details.

## Copyright

Copyright (c) 2017 Jordan Hollinger
