#default config values are set here

AppConfig = {
  :port => 4578,
  :environment => ENV['RACK_ENV'] || 'production',
  :adapter => 'sqlite'
}

AppConfig[:logfile] = if AppConfig[:environment] == 'production'
                        './rest-assured.log'
                      else
                        File.expand_path("../../../#{AppConfig[:environment]}.log", __FILE__)
                      end
