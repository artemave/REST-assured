class Redirect < ActiveRecord::Base
  validates_presence_of :pattern, :to
end
