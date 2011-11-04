require 'yaml'

module WorldHelpers
  def fake_start_rest_assured(options)
    rest_assured_exec = File.expand_path '../../../bin/rest-assured', __FILE__
    code = File.read rest_assured_exec

    code.sub!(/RestAssured::Application.run!/, 'puts AppConfig.to_yaml')

    new_exec = "#{rest_assured_exec}_temp"
    File.open(new_exec, 'w') do |file|
      file.write code
    end

    `chmod +x #{new_exec}`

    config_yaml = `#{new_exec} #{options}`

    `rm #{new_exec}`

    YAML.load(config_yaml)
  end
end
