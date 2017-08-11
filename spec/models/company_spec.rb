require 'rails_helper'

RSpec.describe Company do
  it 'has a valid factory' do
    expect(create(:company)).to be_valid
  end

  describe 'attribute validation' do
    it 'requires a name' do
      expect(build(:company, name: nil)).not_to be_valid
    end

    it 'requires a code' do
      expect(build(:company, code: nil)).not_to be_valid
    end

    it 'limits code to 4–6 alphanumeric characters' do
      expect(build(:company, code: 'sally-jo')).not_to be_valid
    end
  end

  describe 'association methods' do
    it 'has #admin?' do
    end
  end

  describe 'facilitates supplier-purchaser relationships' do
    it 'automatically becomes a supplier’s purchaser' do
      # acme.add_supplier(buynlarge)
      expect(buynlarge.purchasers).to include(acme)
    end

    it 'automatically becomes a purchaser’s supplier' do
      # acme.add_purchaser(cyberdyne)
      expect(cyberdyne.suppliers).to include(acme)
    end

    it 'prevents redundant relations' do
      buynlarge # initiate supply link
      expect { acme.add_supplier(buynlarge) }.not_to change { acme.suppliers.count }
    end
  end
end
