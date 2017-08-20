# awesome_loader [![Build Status](https://travis-ci.org/jhollinger/awesome_loader.svg?branch=master)](https://travis-ci.org/jhollinger/awesome_loader)

So you've created your bespoke Ruby application without Rails. Then you thought, "Bollocks, I have to manually require all my application files, and in a certain order! And I have to explicitly define all my submodules - they don't magically appear based on the directory structure like they did in Rails. There has to be a better way!" Well now there is.

## Install

Add to your Gemfile.

    gem 'awesome_loader'

## Basic Usage

Let's say you have a fairly simple layout, somewhat inspired by Rails.

* `app/models/widget.rb` contains `class Widget`
* `app/models/billing/line_item.rb` contains `class Billing::LineItem`
* `app/helpers/app_helpers.rb` contains `module AppHelpers`

Given those files and their contents, this is all you have to tell `awesome_loader`. Awesome, right?

    AwesomeLoader.autoload do
      paths %w(app ** *.rb)
    end

## Advanced Usage

Maybe your app structure is more complicated. That's fine too. Note the `root_depth: 2` argument. That's saying, "Only start creating modules for dirs after the first 2 levels." That means `app` and `app/*` won't get any modules, but deeper directories, like `app/models/billing`, will. `2` is the default, as you can see in the above example.

    AwesomeLoader.autoload root_depth: 2 do
      # These files have top-level Routes and Entities modules
      paths %w(app routes ** *.rb), root_depth: 1
      paths %w(app entities ** *.rb), root_depth: 1

      # Load everything else using the default root_depth
      paths %w(app ** *.rb)

      # Load your app's initializers. Any classes/modules in them will be autoloaded.
      require %w(config initializers *.rb)
    end

For more details and options, [check out the documentation](http://www.rubydoc.info/gems/awesome_loader/1.1.0).

## Eager Loading

If you're running a threaded server like Puma or Thin, it's usually considered best practice to load everything up-front (at least in production), instead of lettings things load while other threads might be running. The `eager_load` option will ensure that all files are loaded before the block exits.

    AwesomeLoader.autoload eager_load: is_prod? do
      paths %w(app ** *.rb)
    end

## License

MIT License. See LICENSE for details.

## Copyright

Copyright (c) 2017 Jordan Hollinger
