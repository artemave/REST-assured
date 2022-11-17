require 'active_record'
require 'net/http'

module RestAssured
  module Models
    class Double < ActiveRecord::Base
      serialize :response_headers, Hash

      VERBS = %w{GET POST PUT DELETE HEAD PATCH OPTIONS}
      STATUSES = Net::HTTPResponse::CODE_TO_OBJ.keys.map(&:to_i)
      MAX_DELAY = 30

      validate :fullpath_or_pattern
      validate :pattern_is_regex
      validates_inclusion_of :verb, :in => VERBS
      validates_inclusion_of :status, :in => STATUSES

      after_initialize :set_status
      after_initialize :set_verb
      after_initialize :set_response_headers
      after_initialize :set_delay
      after_initialize :stringify_regexp

      before_save :toggle_active
      after_destroy :set_active

      has_many :requests, :dependent => :destroy

      private

        def toggle_active
          ne = id ? '!=' : 'IS NOT'

          if active && Double.where("fullpath = ? AND verb = ? AND active = ? AND id #{ne} ?", fullpath, verb, true, id).exists?
            Double.where("fullpath = ? AND verb = ? AND id #{ne} ?", fullpath, verb, id).update_all :active => false
          end
        end

        def set_response_headers
          self.response_headers = {} unless response_headers.present? # present? protects against empty strings that may come in parameters
        end

        def set_verb
          self.verb = 'GET' unless verb.present?
        end

        def set_status
          self.status = 200 unless status.present?
        end

        def set_active
          if active && f = Double.where(:fullpath => fullpath).last
            f.active = true
            f.save
          end
        end

      def set_delay
          self.delay = 0 unless delay.present?
          if self.delay > MAX_DELAY
            puts "delay #{self.delay} exceeds maxmium.  Defaulting to #{MAX_DELAY}"
            self.delay = MAX_DELAY
          end
      end

      def fullpath_or_pattern
        unless self.fullpath.blank? ^ self.pathpattern.blank?
          errors.add(:path, "Exactly one of fullpath or pathpattern must be present")
        end
      end

      def pattern_is_regex
        unless self.pathpattern.blank?
          begin
            Regexp.new(self.pathpattern)
          rescue RegexpError
            errors.add(:pathpattern, "not a valid regular expression")
          end
        end
      end

      def stringify_regexp
        unless self.pathpattern.blank?
          self.pathpattern = self.pathpattern.to_s
        end
      end
    end
  end
end
