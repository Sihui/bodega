require 'rails_helper'

RSpec.describe Commitment, type: :model do
  it 'has a valid factory' do
    expect(create(:commitment)).to be_valid
  end

  describe 'attribute validation' do
    it 'requires a User' do
      expect(build(:commitment, user: nil)).not_to be_valid
    end

    it 'requires a Company' do
      expect(build(:commitment, company: nil)).not_to be_valid
    end

    it 'defaults to not-admin without an admin flag' do
      expect(create(:commitment).admin?).to be(false)
    end

    it 'limits users to one commitment per company' do
      orig = create(:commitment)
      expect(build(:commitment, user: orig.user, company: orig.company))
        .not_to be_valid
    end
  end

  describe 'association methods' do
    it 'has ::between (happy path)' do
      expect(Commitment.between(alice, acme)).to be_present
    end

    it 'has ::between (no false negatives)' do
      expect(Commitment.between(alice, buynlarge)).not_to be_present
    end
  end

  describe 'confirmability' do
    it 'has #confirmed? (happy path)' do
      expect(Commitment.between(alice, acme).confirmed?).to be(true)
    end

    it 'has #confirmed? (no false negatives)' do
      # acme.add_member(amelia, pending: :admin)
      expect(Commitment.between(amelia, acme).confirmed?).to be(false)
    end

    it 'has #confirm!' do
      expect { Commitment.between(amelia, acme).confirm! }
        .to change { Commitment.between(amelia, acme).confirmed? }.to(true)
    end
  end
end
