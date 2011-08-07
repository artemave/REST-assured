class Fixture < ActiveRecord::Base
  validates_presence_of :url, :content
end
