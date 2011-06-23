class Fixture < ActiveRecord::Base
end

if $0 == __FILE__
  require 'test/unit'

  class TestFixtureModel < Test::Unit::TestCase
    def setup
      AddFixtureTable.up
      @fixture = Fixture.new
    end
    
    def teardown
      AddFixtureTable.down
    end

    def test_fixture_attributes_exist
      [:url, :content].each do |method|
        assert_respond_to @fixture, method, "#{@fixture.class.name} should have instance method called #{method.to_s}"
      end
    end

    def test_fixture_class_methods_exist
      [:create].each do |method|
        assert_respond_to Fixture, method, "#{@fixture.class.name} should have class method called #{method.to_s}"
      end
     end
  end
end
