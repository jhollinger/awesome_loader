# awesome_loader

An awesome way to load your (non-Rails) Ruby application! Tired of tons of manual requires? Me too! So I made this little gem to augment Ruby's built-in `autoload` functionality. Works pretty much the same as in Rails. (NOTE Don't confuse this with auto-**re**loading.)

## Install

Just add to your Gemfile.

    gem 'awesome_loader'

## Basic Usage

`awesome_loader` assumes that your directories and files are all in "snake case" (my_dir/my_file.rb), and that your Ruby Modules and Classes are all in "camel case" (MyDir::MyFile). Additionally, it assumes that your directory structure matches your Module structure. In fact it will traverse your directory tree and make sure all those Modules are created for you.

Let's say you have a fairly simple layout, somewhat inspired by Rails.

* `app/models/user.rb` contains `User`
* `app/models/widget.rb` contains `Widget`
* `app/models/billing/line_item.rb` contains `Billing::LineItem`
* `app/helpers/app_helpers.rb` contains `AppHelpers`

Given the those files and their contents, this is all you have to tell `awesome_loader`. Note the `root_depth: 2` argument. That's saying, "Only start creating modules for dirs after the first 2 levels." That means `app/*` won't get any modules, but deeper directories, like `app/models/billing`, will.

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

If you're running a threaded server like Puma or Thin, it's usually considered best practice to load everything up-front (at least in production), instead of lettings things load while other threads might be running. The `eager_load` option will ensure that all files are loaded before the block exits.

    AwesomeLoader.autoload root_depth: 2, eager_load: true do
      paths %w(app ** *.rb)
    end

## License

MIT License. See LICENSE for details.

## Copyright

Copyright (c) 2017 Jordan Hollinger
