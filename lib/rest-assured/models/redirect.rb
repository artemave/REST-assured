module RestAssured
  module Models
    class Redirect < ActiveRecord::Base
      validates_presence_of :pattern, :to

      scope :ordered, -> { order('position') }

      before_create :assign_position

      def self.find_redirect_url_for(fullpath)
        if redirect = ordered.find { |r| fullpath =~ /#{r.pattern}/ }
          fullpath.sub /#{redirect.pattern}/, redirect.to
        end
      end

      def self.update_order(ordered_redirect_ids)
        success = true

        transaction do
          begin
            ordered_redirect_ids.each_with_index do |r_id, idx|
              r = find(r_id)
              r.position = idx
              r.save!
            end
          rescue => e
            # TODO log exception
            puts e.inspect
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
  end
end
