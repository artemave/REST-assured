class Fixture < ActiveRecord::Base
  validates_presence_of :url, :content

  before_save :toggle_active
  after_destroy :set_active

  private
    def toggle_active
      if active && Fixture.where(url: url, active: true).exists?
        Fixture.update_all active: false
      end
    end

    def set_active
      if active && f = Fixture.where(url: url).last
        f.active = true
        f.save
      end
    end
end
