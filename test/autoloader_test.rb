require 'test_helper'
require 'tmpdir'
require 'fileutils'

class AutoloaderTest < Minitest::Test
  include TestHelpers

  App1 = Module.new
  App2 = Module.new

  def app_files(root_module)
    {
      'app/models/widget.rb' => "class #{root_module.name}::Widget; end",
      'app/models/billing/line_item.rb' => "class #{root_module.name}::Billing::LineItem; end",
      'app/features/billing/recurring/monthly/run.rb' => "class #{root_module.name}::Billing::Recurring::Monthly::Run; end",
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
      assert App2::Billing.autoload? :LineItem
      assert App2::Billing::Recurring::Monthly.autoload? :Run
      assert App2::Billing::LineItem.is_a?(Class)
      assert App2::Billing::Recurring::Monthly::Run.is_a?(Class)
    end
  end
end
