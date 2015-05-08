require 'yaml'
require 'open3'

module WorldHelpers
  def fake_start_rest_assured(options)
    rest_assured_exec = File.expand_path '../../../bin/rest-assured', __FILE__
    code = File.read rest_assured_exec

    code.sub!(/require 'rest-assured\/application'/, '')
    code.sub!(/RestAssured::Application.run!.*/m, 'require "yaml"; puts AppConfig.to_yaml')

    new_exec = "#{rest_assured_exec}_temp"
    File.open(new_exec, 'w') do |file|
      file.write code
    end

    `chmod +x #{new_exec}`

    config_yaml, _, _ = Open3.capture3({'RACK_ENV' => 'production'}, new_exec, *options.split(' '))

    `rm #{new_exec}`

    YAML.load(config_yaml)
  end
end
