require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:user)).to be_valid
  end

  it 'requires a name' do
    expect(FactoryGirl.build(:user, name: nil)).not_to be_valid
  end

  it 'requires an email' do
    expect(FactoryGirl.build(:user, email: nil)).not_to be_valid
  end

  it 'rejects invalid email' do
    expect(FactoryGirl.build(:user, email: Faker::Name.name)).not_to be_valid
  end

  it 'requires a password' do
    expect(FactoryGirl.build(:user, password: nil)).not_to be_valid
  end

  it 'rejects short passwords' do
    expect(FactoryGirl.build(:user, password: '12345')).not_to be_valid
  end
end
