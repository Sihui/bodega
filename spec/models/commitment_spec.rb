require 'rails_helper'

RSpec.describe Commitment, type: :model do
  it 'has a valid factory' do
    expect(create(:commitment)).to be_valid
  end

  it 'requires a User' do
    expect(build(:commitment, user: nil)).not_to be_valid
  end

  it 'requires a Company' do
    expect(build(:commitment, company: nil)).not_to be_valid
  end

  it 'defaults to not-admin without an admin flag' do
    expect(create(:commitment).admin).to be(false)
  end
end
