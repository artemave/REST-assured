require_relative '../spec_helper'

describe Fixture do
  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:content) }
end
