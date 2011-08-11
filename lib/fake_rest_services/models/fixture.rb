class Fixture < ActiveRecord::Base
  validates_presence_of :url, :content

  before_save :toggle_active

  private
    def toggle_active
      if active && Fixture.where(url: url, active: true).exists?
        Fixture.update_all active: false
      end
    end
end
