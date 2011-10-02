# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spork', :cucumber_env => { 'RACK_ENV' => 'test' }, :rspec_env => { 'RACK_ENV' => 'test' } do
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb')
  watch(%r{features/support/.+\.rb$})
  watch(%r{^lib/.+\.rb$})
end
