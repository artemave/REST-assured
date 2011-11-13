require 'net/http'

module RestAssured
  module Models
    class Double < ActiveRecord::Base
      attr_accessible :fullpath, :content, :description, :verb, :status

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

        if active && Double.where("fullpath = ? AND active = ? AND id #{ne} ?", fullpath, true, id).exists?
          Double.where("fullpath = ? AND id #{ne} ?", fullpath, id).update_all :active => false
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
