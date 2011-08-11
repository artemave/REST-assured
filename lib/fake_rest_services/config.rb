AppConfig = {
  port: 4578,
  environment: ENV['RACK_ENV'] || 'production'
}

AppConfig[:database] = case AppConfig[:environment]
                       when 'production'
                         './fake_rest_services.db'
                       else
                         File.expand_path("../../../db/#{AppConfig[:environment]}.db", __FILE__)
                       end
