class Request < ActiveRecord::Base
  belongs_to :double

  validates_presence_of :body, :headers

  after_create :save_created_at

  private
    def save_created_at
      self.created_at = Time.now
    end
end
