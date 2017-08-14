require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(create(:user)).to be_valid
  end

  describe 'attribute validation' do
    it 'requires a non-nil name' do
      expect(build(:user, name: nil)).not_to be_valid
    end

    it 'requires a non-blank name' do
      expect(build(:user, name: ' ')).not_to be_valid
    end

    it 'requires a non-nil email' do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it 'requires an email containing an ‘@’ symbol' do
      expect(build(:user, email: 'email.com')).not_to be_valid
    end

    it 'requires a non-nil password' do
      expect(build(:user, password: nil)).not_to be_valid
    end

    it 'requires a password 6+ characters long' do
      expect(build(:user, password: '12345')).not_to be_valid
    end
  end

  describe 'custom association methods' do
    include_context 'roster'

    it 'has #belongs_to? (happy path)' do
      expect(alice.belongs_to?(acme)).to be(true)
    end

    it 'has #belongs_to? (no false positives)' do
      expect(alice.belongs_to?(buynlarge)).to be(false)
    end

    it 'has #is_admin? (happy path)' do
      expect(alice.is_admin?(acme)).to be(true)
    end

    it 'has #is_admin? (no false positives)' do
      expect(arthur.is_admin?(acme)).to be(false)
    end

    it 'has #is_purchaser? (happy path)' do
      expect(alice.is_purchaser?(buynlarge)).to be(true)
    end

    it 'has #is_purchaser? (no false positives)' do
      expect(bob.is_purchaser?(acme)).to be(false)
    end
  end
end
