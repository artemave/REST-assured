AppConfig = {
  :port => 4578,
  :environment => ENV['RACK_ENV'] || 'production'
}

AppConfig[:database] = if AppConfig[:environment] == 'production'
                         './rest-assured.db'
                       else
                         File.expand_path("../../../db/#{AppConfig[:environment]}.db", __FILE__)
                       end

AppConfig[:log_file] = if AppConfig[:environment] == 'production'
                         './rest-assured.log'
                       else
                         File.expand_path("../../../#{AppConfig[:environment]}.log", __FILE__)
                       end
