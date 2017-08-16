require 'active_record'
require 'net/http'

module RestAssured
  module Models
    class Double < ActiveRecord::Base
      serialize :response_headers, Hash

      VERBS = %w{GET POST PUT DELETE HEAD PATCH}
      STATUSES = Net::HTTPResponse::CODE_TO_OBJ.keys.map(&:to_i)
      MAX_DELAY = 30_000

      validates_presence_of :fullpath
      validates_inclusion_of :verb, :in => VERBS
      validates_inclusion_of :status, :in => STATUSES

      after_initialize :set_status
      after_initialize :set_verb
      after_initialize :set_response_headers
      after_initialize :set_delay

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
    end
  end
end
