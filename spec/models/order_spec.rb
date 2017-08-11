require 'rails_helper'

RSpec.describe Order, type: :model do
  it 'has a valid factory' do
    expect(create(:order)).to be_valid
  end

  describe 'attribute validation' do
    it 'requires a supplier' do
      expect(build(:order, supplier_id: nil)).not_to be_valid
    end

    it 'requires a purchaser' do
      expect(build(:order, purchaser_id: nil)).not_to be_valid
    end

    it 'requires an order-placer' do
      expect(build(:order, placed_by: nil)).not_to be_valid
    end

    it 'requires order-placer to belong to purchaser' do
      expect(build(:order, placed_by: create(:user))).not_to be_valid
    end

    it 'requires order-accepter to belong to supplier' do
      expect(build(:order, accepted_by: create(:user))).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'automatically generates an invoice number' do
      expect(create(:order, invoice_no: nil).invoice_no).not_to be nil
    end
  end
end
