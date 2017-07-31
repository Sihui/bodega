require 'rails_helper'

RSpec.describe Item, type: :model do
  it 'has a valid factory' do
    expect(create(:item)).to be_valid
  end

  describe 'attribute validation' do
    it 'requires a Supplier' do
      expect(build(:item, supplier: nil)).not_to be_valid
    end

    it 'prevents redundant objects' do
      orig = create(:item)
      expect(build(:item, name: orig.name, supplier: orig.supplier))
        .not_to be_valid
    end
  end
end
