require 'rails_helper'

RSpec.describe Commitment, type: :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:commitment)).to be_valid
  end

  it 'belongs to a User'
end
