require 'rails_helper'

RSpec.describe SupplyLink, type: :model do
  it 'has a valid factory' do
    expect(create(:supply_link)).to be_valid
  end

  describe 'attribute validation' do
    it 'requires a Supplier' do
      expect(build(:supply_link, supplier: nil)).not_to be_valid
    end

    it 'requires a Purchaser' do
      expect(build(:supply_link, purchaser: nil)).not_to be_valid
    end

    it 'prevents redundant objects' do
      orig = create(:supply_link)
      expect(build(:supply_link, supplier: orig.supplier, purchaser: orig.purchaser))
        .not_to be_valid
    end
  end

  describe 'association methods' do
    include_context 'roster'
    it 'has ::between (happy path)' do
      expect(SupplyLink.between(acme, buynlarge)).to be_present
    end

    it 'has ::between (no false negatives)' do
      expect(SupplyLink.between(acme, zorg)).not_to be_present
    end

    it 'has ::for (happy path)' do
      expect(SupplyLink.for(supplier: acme, purchaser: cyberdyne)).to be_present
    end

    it 'has ::for (no false negatives)' do
      expect(SupplyLink.for(supplier: acme, purchaser: buynlarge)).not_to be_present
    end
  end

  describe 'confirmability' do
    include_context 'roster'
    it 'has #confirmed? (happy path)' do
      expect(SupplyLink.between(acme, buynlarge).confirmed?).to be(true)
    end

    it 'has #confirmed? (no false negatives)' do
      # acme.add_supplier(bluthco)
      expect(SupplyLink.between(acme, bluthco).confirmed?).to be(false)
    end

    it 'has #confirm!' do
      expect { SupplyLink.between(acme, bluthco).confirm! }
        .to change { SupplyLink.between(acme, bluthco).confirmed? }.to(true)
    end
  end
end
