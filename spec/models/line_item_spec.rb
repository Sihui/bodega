require 'rails_helper'

RSpec.describe LineItem, type: :model do
  it 'has a valid factory' do
    expect(create(:line_item)).to be_valid
  end

  describe 'attribute completion' do
    it 'calculates a total' do
      line_item = create(:line_item, qty: 3)
      expect(line_item.total).to eq(line_item.item.price * line_item.qty)
    end
  end
end
