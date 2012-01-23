require 'net/http'

module RestAssured
  module Models
    class Double < ActiveRecord::Base
      attr_accessible :fullpath, :content, :description, :verb, :status, :response_headers

      serialize :response_headers, Hash

      VERBS = %w{GET POST PUT DELETE}
      STATUSES = Net::HTTPResponse::CODE_TO_OBJ.keys.map(&:to_i)

      validates_presence_of :fullpath
      validates_inclusion_of :verb, :in => VERBS
      validates_inclusion_of :status, :in => STATUSES

      before_save :toggle_active
      before_validation :set_verb
      before_validation :set_status
      after_destroy :set_active

      has_many :requests, :dependent => :destroy

      private

        def toggle_active
          ne = id ? '!=' : 'IS NOT'

          if active && Double.where("fullpath = ? AND verb = ? AND active = ? AND id #{ne} ?", fullpath, verb, true, id).exists?
            Double.where("fullpath = ? AND verb = ? AND id #{ne} ?", fullpath, verb, id).update_all :active => false
          end
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
    end
  end
end
