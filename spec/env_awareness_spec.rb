require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/rest-assured/utils/env_awareness', __FILE__)

module RestAssured::Utils
  describe EnvAwareness do
    let :extendee do
      o = Object.new
      o.extend(EnvAwareness)
      o
    end

    #TODO

  end
end
