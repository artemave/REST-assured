require 'yaml'

module WorldHelpers
  def fake_start_rest_assured(options)
    rest_assured_exec = File.expand_path '../../../bin/rest-assured', __FILE__
    code = File.read rest_assured_exec

    code.sub! /.*/ do |shebang|
      shebang + "\nENV['RACK_ENV'] = 'production'"
    end
    code.sub!(/RestAssured::Application.run!/, 'puts AppConfig.to_yaml')

    new_exec = "#{rest_assured_exec}_temp"
    File.open(new_exec, 'w') do |file|
      file.write code
    end

    `chmod +x #{new_exec}`

    puts "#{new_exec} #{options}"
    stdout_str, stderr_str, status = Open3.capture3({'RACK_ENV' => 'production'}, cmd... [, opts])
    puts "CONF: #{config_yaml}"

    #`rm #{new_exec}`

    YAML.load(config_yaml)
  end
end
