require 'yaml'
require 'open3'

module WorldHelpers
  def fake_start_rest_assured(options)
    rest_assured_exec = File.expand_path '../../../bin/rest-assured', __FILE__
    code = File.read rest_assured_exec

    code.sub!(/(.*)/, "\\1\nENV['RACK_ENV'] = 'production'")
    code.sub!(/require 'rest-assured\/application'/, '')
    code.sub!(/RestAssured::Application.run!.*/m, 'puts AppConfig.to_yaml')

    new_exec = "#{rest_assured_exec}_temp"
    File.open(new_exec, 'w') do |file|
      file.write code
    end

    `chmod +x #{new_exec}`

    # this is 1.9.X version. So much more useful than 1.8 (uncommented). Sigh...
    #config_yaml, stderr_str, status = Open3.capture3({'RACK_ENV' => 'production'}, new_exec, *options.split(' '))
    config_yaml = nil
    Open3.popen3(new_exec, *options.split(' ')) do |stdin, stdout, stderr|
      config_yaml = stdout.read
    end

    `rm #{new_exec}`

    YAML.load(config_yaml)
  end
end
