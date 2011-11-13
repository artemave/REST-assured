module RestAssured
  module Models
    class Request < ActiveRecord::Base
      belongs_to :double

      validates_presence_of :rack_env

      after_create :save_created_at

      private
        def save_created_at
          self.created_at = Time.now
        end
    end
  end
end
