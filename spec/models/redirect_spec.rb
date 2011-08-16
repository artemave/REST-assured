require_relative '../spec_helper'

describe Redirect do
  it { should validate_presence_of(:pattern) }
  it { should validate_presence_of(:to) }
end
