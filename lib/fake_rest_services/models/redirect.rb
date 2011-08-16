class Redirect < ActiveRecord::Base
  attr_accessible :pattern, :to

  validates_presence_of :pattern, :to
end
