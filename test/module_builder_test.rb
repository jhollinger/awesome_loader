require 'test_helper'

class ModuleBuilderTest < Minitest::Test
  def test_module_names_with_0_depth
    builder = AwesomeLoader::ModuleBuilder.new(root_depth: 0)
    assert_equal [], builder.module_names('.')
    assert_equal ['App'], builder.module_names('app')
    assert_equal ['App', 'Models'], builder.module_names('app/models')
    assert_equal ['App', 'Models', 'Billing'], builder.module_names('app/models/billing')
    assert_equal ['App', 'Models', 'Billing', 'Recurring'], builder.module_names('app/models/billing/recurring')
    assert_equal ['App', 'Models', 'Billing', 'Recurring', 'Monthly'], builder.module_names('app/models/billing/recurring/monthly')
  end

  def test_module_names_with_1_depth
    builder = AwesomeLoader::ModuleBuilder.new(root_depth: 1)
    assert_equal [], builder.module_names('.')
    assert_equal [], builder.module_names('app')
    assert_equal ['Models'], builder.module_names('app/models')
    assert_equal ['Models', 'Billing'], builder.module_names('app/models/billing')
    assert_equal ['Models', 'Billing', 'Recurring'], builder.module_names('app/models/billing/recurring')
    assert_equal ['Models', 'Billing', 'Recurring', 'Monthly'], builder.module_names('app/models/billing/recurring/monthly')
  end

  def test_module_names_with_2_depth
    builder = AwesomeLoader::ModuleBuilder.new(root_depth: 2)
    assert_equal [], builder.module_names('.')
    assert_equal [], builder.module_names('app')
    assert_equal [], builder.module_names('app/models')
    assert_equal ['Billing'], builder.module_names('app/models/billing')
    assert_equal ['Billing', 'Recurring'], builder.module_names('app/models/billing/recurring')
    assert_equal ['Billing', 'Recurring', 'Monthly'], builder.module_names('app/models/billing/recurring/monthly')
  end

  def test_module_names_with_3_depth
    builder = AwesomeLoader::ModuleBuilder.new(root_depth: 3)
    assert_equal [], builder.module_names('.')
    assert_equal [], builder.module_names('app')
    assert_equal [], builder.module_names('app/models')
    assert_equal [], builder.module_names('app/models/billing')
    assert_equal ['Recurring'], builder.module_names('app/models/billing/recurring')
    assert_equal ['Recurring', 'Monthly'], builder.module_names('app/models/billing/recurring/monthly')
  end

  def test_module_with_0_depth
    builder = AwesomeLoader::ModuleBuilder.new(root_depth: 0)
    assert_equal 'Object', builder.module('.').name
    assert_equal 'App', builder.module('app').name
    assert_equal 'App::Models', builder.module('app/models').name
    assert_equal 'App::Models::Billing', builder.module('app/models/billing').name
    assert_equal 'App::Models::Billing::Recurring', builder.module('app/models/billing/recurring').name
    assert_equal 'App::Models::Billing::Recurring::Monthly', builder.module('app/models/billing/recurring/monthly').name
  end

  def test_module_with_1_depth
    builder = AwesomeLoader::ModuleBuilder.new(root_depth: 1)
    assert_equal 'Object', builder.module('.').name
    assert_equal 'Object', builder.module('app').name
    assert_equal 'Models', builder.module('app/models').name
    assert_equal 'Models::Billing', builder.module('app/models/billing').name
    assert_equal 'Models::Billing::Recurring', builder.module('app/models/billing/recurring').name
    assert_equal 'Models::Billing::Recurring::Monthly', builder.module('app/models/billing/recurring/monthly').name
  end

  def test_module_with_2_depth
    builder = AwesomeLoader::ModuleBuilder.new(root_depth: 2)
    assert_equal 'Object', builder.module('.').name
    assert_equal 'Object', builder.module('app').name
    assert_equal 'Object', builder.module('app/models').name
    assert_equal 'Billing', builder.module('app/models/billing').name
    assert_equal 'Billing::Recurring', builder.module('app/models/billing/recurring').name
    assert_equal 'Billing::Recurring::Monthly', builder.module('app/models/billing/recurring/monthly').name
  end

  def test_module_with_3_depth
    builder = AwesomeLoader::ModuleBuilder.new(root_depth: 3)
    assert_equal 'Object', builder.module('.').name
    assert_equal 'Object', builder.module('app').name
    assert_equal 'Object', builder.module('app/models').name
    assert_equal 'Object', builder.module('app/models/billing').name
    assert_equal 'Recurring', builder.module('app/models/billing/recurring').name
    assert_equal 'Recurring::Monthly', builder.module('app/models/billing/recurring/monthly').name
  end
end
