RSpec::Matchers.define :validate_inclusion_of do |field, list|
  match do |actual|
    list.each do |i|
      actual.should allow_value(i).for(field)
    end
  end
end
