require 'active_support/core_ext/class/attribute_accessors'

module FakeRestServices
  class Options
    cattr_accessor :database, :port
  end
end
