require 'rails_helper'

RSpec.describe Company do
  it 'has a valid factory' do
    expect(create(:company)).to be_valid
  end

  it 'requires a name' do
    expect(build(:company, name: nil)).not_to be_valid
  end

  describe 'supports supplier-purchaser relationships' do
    let :purch { create(:company, :with_supplier) }
    let :suppl { create(:company, :with_purchaser) }

    it 'automatically becomes a supplier’s purchaser' do
      expect(purch.suppliers.map(&:purchasers).flatten).to include(purch)
    end

    it 'automatically becomes a purchaser’s supplier' do
      expect(suppl.purchasers.map(&:suppliers).flatten).to include(suppl)
    end

    it 'prevents redundant relations' do
      suppliers = purch.suppliers
      expect { suppliers << suppliers.first }.not_to change { suppliers.count }
    end
  end
end
