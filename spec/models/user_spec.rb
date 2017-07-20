require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(create(:user)).to be_valid
  end

  describe 'requires a name' do
    it 'must not be nil' do
      expect(build(:user, name: nil)).not_to be_valid
    end

    it 'must not be blank' do
      expect(build(:user, name: ' ')).not_to be_valid
    end
  end

  describe 'requires an email' do
    it 'must not be nil' do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it 'must contain an ‘@’' do
      expect(build(:user, email: 'email.com')).not_to be_valid
    end
  end

  describe 'requires an password' do
    it 'must not be nil' do
      expect(build(:user, password: nil)).not_to be_valid
    end

    it 'must be 6+ characters long' do
      expect(build(:user, password: '12345')).not_to be_valid
    end
  end
end
