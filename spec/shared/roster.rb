RSpec.shared_context "roster" do
  # ACME ===================================================================
  let(:acme)       { create(:company) }

  # Staff ------------------------------------------------------------------
  let(:alice)      { create(:user, :registered, from: acme, admin: true) }
  let(:arthur)     { create(:user, :registered, from: acme) }
  let(:amelia)     { create(:user, :registered, from: acme, pending: :admin) }
  let(:andrew)     { create(:user, :registered, from: acme, pending: :member) }
  let(:aaron_burr) { create(:user, :registered, from: [acme, buynlarge], admin: true) }

  # ACME’s Suppliers =======================================================
  let(:buynlarge) { create(:company, purchaser: acme) }
  let(:bob)       { create(:user, :registered, from: buynlarge) }

  let(:bluthco)   { create(:company, purchaser: acme, pending: :supplier) }
  let(:barry)     { create(:user, :registered, from: bluthco, admin: true) }

  # ACME’s Purchasers ======================================================
  let(:cyberdyne) { create(:company, supplier: acme) }
  let(:carol)     { create(:user, :registered, from: cyberdyne) }

  let(:cogswell)  { create(:company, supplier: acme, pending: :supplier) }

  # Unaffiliated Companies =================================================
  let(:zorg) { create(:company) }
  let(:zack) { create(:user, :registered) }
end
