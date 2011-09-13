class Redirect < ActiveRecord::Base
  attr_accessible :pattern, :to

  validates_presence_of :pattern, :to
  validates_uniqueness_of :position, :allow_blank => true

  scope :ordered, order('position')

  before_create :assign_position

  def self.update_order(ordered_redirect_ids)
    success = true

    transaction do
      begin
        update_all :position => nil

        ordered_redirect_ids.each_with_index do |r_id, idx|
          r = find(r_id)
          r.position = idx
          r.save!
        end
      rescue
        # TODO log exception
        success = false
        raise ActiveRecord::Rollback
      end
    end
    success
  end

  private

    def assign_position
      self.position = ( self.class.maximum(:position) || -1 ) + 1
    end
end
