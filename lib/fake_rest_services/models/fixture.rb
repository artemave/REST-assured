class Fixture < ActiveRecord::Base
  #TODO rspec
  validates_presence_of :url, :content
end
