CAPTURE_A_NUMBER = Transform /^\d+$/ do |n|
  n.to_i
end
