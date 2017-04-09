# awesome_loader

So you've created your bespoke Ruby application without Rails. Then you thought, "Bollocks, I have to manually require all my application files, and in a certain order! Plus I must explicitly define all my submodules - they don't magically appear based on the directory structure like they did in Rails. There has to be a better way!" Well now there is.

## Install

Add to your Gemfile.

    gem 'awesome_loader'

## Basic Usage

Let's say you have a fairly simple layout, somewhat inspired by Rails.

* `app/models/widget.rb` contains `class Widget`
* `app/models/billing/line_item.rb` contains `class Billing::LineItem`
* `app/helpers/app_helpers.rb` contains `module AppHelpers`

Given those files and their contents, this is all you have to tell `awesome_loader`. Note the `root_depth: 2` argument. That's saying, "Only start creating modules for dirs after the first 2 levels." That means `app` and `app/*` won't get any modules, but deeper directories, like `app/models/billing`, will.

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

For more details and options, [check out the documentation](http://www.rubydoc.info/gems/awesome_loader).

## Eager Loading

If you're running a threaded server like Puma or Thin, it's usually considered best practice to load everything up-front (at least in production), instead of lettings things load while other threads might be running. The `eager_load` option will ensure that all files are loaded before the block exits.

    AwesomeLoader.autoload root_depth: 2, eager_load: true do
      paths %w(app ** *.rb)
    end

## License

MIT License. See LICENSE for details.

## Copyright

Copyright (c) 2017 Jordan Hollinger
