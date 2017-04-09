require 'test_helper'
require 'tmpdir'
require 'fileutils'

class AutoloaderTest < Minitest::Test
  include TestHelpers

  App1 = Module.new
  App2 = Module.new
  App3 = Module.new
  App4 = Module.new

  def setup
    $global_var = 0
  end

  def app_files(root_module = nil)
    prefix = root_module ? "#{root_module.name}::" : ''
    {
      'app/models/widget.rb' => "class #{prefix}Widget; end; $global_var = 1;",
      'app/models/billing/line_item.rb' => "class #{prefix}Billing::LineItem; end",
      'app/features/billing/recurring/monthly/run.rb' => "class #{prefix}Billing::Recurring::Monthly::Run; end",
    }
  end

  def test_loader_creates_modules
    tmp_app app_files(App1) do |app_root|
      AwesomeLoader::Autoloader.new(root_depth: 2, root_path: app_root, root_module: App1).
        paths(%w(app ** *.rb))
      refute App1.const_defined?('App', false)
      refute App1.const_defined?('Models', false)
      refute App1.const_defined?('Features', false)
      assert App1.const_defined?('Billing', false)
      assert App1.const_defined?('Billing::Recurring', false)
      assert App1.const_defined?('Billing::Recurring::Monthly', false)
    end
  end

  def test_loader_enables_autoload
    tmp_app app_files(App2) do |app_root|
      AwesomeLoader::Autoloader.new(root_depth: 2, root_path: app_root, root_module: App2).
        paths(%w(app ** *.rb))
      assert App2.autoload? :Widget
      assert App2::Billing.autoload? :LineItem
      assert App2::Billing::Recurring::Monthly.autoload? :Run
      assert App2::Billing::LineItem.is_a?(Class)
      assert App2::Billing::Recurring::Monthly::Run.is_a?(Class)
    end
  end

  def test_doesnt_eager_load_by_default
    tmp_app app_files(App3) do |app_root|
      AwesomeLoader.autoload(root_depth: 2, root_path: app_root, root_module: App3) do
        paths %w(app ** *.rb)
      end
      assert_equal 0, $global_var
    end
  end

  def test_eager_loads_after_block
    tmp_app app_files(App4) do |app_root|
      AwesomeLoader.autoload(root_depth: 2, root_path: app_root, root_module: App4, eager_load: true) do
        paths %w(app ** *.rb)
      end
      assert_equal 1, $global_var
    end
  end

  def test_works_without_specifying_root_module
    tmp_app app_files do |app_root|
      AwesomeLoader::Autoloader.new(root_depth: 2, root_path: app_root).
        paths(%w(app ** *.rb))
      assert ::Billing.autoload? :LineItem
      assert ::Billing::Recurring::Monthly.autoload? :Run
      assert ::Billing::LineItem.is_a?(Class)
      assert ::Billing::Recurring::Monthly::Run.is_a?(Class)
    end
  end
end
