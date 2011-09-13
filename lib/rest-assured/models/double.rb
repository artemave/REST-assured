class Double < ActiveRecord::Base
  attr_accessible :fullpath, :content, :description, :method

  METHODS = %w{GET POST PUT DELETE}

  validates_presence_of :fullpath, :content
  validates_inclusion_of :method, :in => METHODS

  before_save :toggle_active
  before_validation :set_method
  after_destroy :set_active

  private
    def toggle_active
      if active && Double.where(:fullpath => fullpath, :active => true, :id.ne => id).exists?
        Double.where(:fullpath => fullpath, :id.ne => id).update_all :active => false
      end
    end

    def set_method
      self.method = 'GET' unless method.present?
    end

    def set_active
      if active && f = Double.where(:fullpath => fullpath).last
        f.active = true
        f.save
      end
    end
end
