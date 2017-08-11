module Bodega
  module FactoryHelper
    def self.included(b)
      # ACME ===================================================================
      b.let(:acme)       { create(:company) }

      # Staff ------------------------------------------------------------------
      b.let(:alice)      { create(:user, from: acme, admin: true) }
      b.let(:arthur)     { create(:user, from: acme) }
      b.let(:amelia)     { create(:user, from: acme, pending: :admin) }
      b.let(:andrew)     { create(:user, from: acme, pending: :member) }
      b.let(:aaron_burr) { create(:user, from: [acme, buynlarge], admin: true) }

      # ACME’s Suppliers =======================================================
      b.let(:buynlarge) { create(:company, purchaser: acme) }
      b.let(:bob)       { create(:user, from: buynlarge) }

      b.let(:bluthco)   { create(:company, purchaser: acme, pending: :supplier) }
      b.let(:barry)       { create(:user, from: bluthco, admin: true) }

      # ACME’s Purchasers ======================================================
      b.let(:cyberdyne) { create(:company, supplier: acme) }
      b.let(:carol)     { create(:user, from: cyberdyne) }

      b.let(:cogswell)  { create(:company, supplier: acme, pending: :supplier) }

      # Unaffiliated Companies =================================================
      b.let(:zorg) { create(:company) }
      b.let(:zack) { create(:user) }
    end
  end
end
