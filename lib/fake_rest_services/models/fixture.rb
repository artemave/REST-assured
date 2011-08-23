class Fixture < ActiveRecord::Base
  attr_accessible :url, :content, :description, :method

  METHODS = %w{GET POST PUT DELETE}

  validates_presence_of :url, :content
  validates_inclusion_of :method, :in => METHODS

  before_save :toggle_active
  before_validation :set_method
  after_destroy :set_active

  private
    def toggle_active
      if active && Fixture.where(:url => url, :active => true, :id.ne => id).exists?
        Fixture.where(:url => url, :id.ne => id).update_all :active => false
      end
    end

    def set_method
      self.method = 'GET' unless method.present?
    end

    def set_active
      if active && f = Fixture.where(:url => url).last
        f.active = true
        f.save
      end
    end
end
