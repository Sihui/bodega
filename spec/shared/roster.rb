RSpec.shared_context "roster" do
  # ACME ===================================================================
  let(:acme)       { create(:company) }

  # Staff ------------------------------------------------------------------
  let(:alice)      { create(:user, from: acme, admin: true) }
  let(:arthur)     { create(:user, from: acme) }
  let(:amelia)     { create(:user, from: acme, pending: :admin) }
  let(:andrew)     { create(:user, from: acme, pending: :member) }
  let(:aaron_burr) { create(:user, from: [acme, buynlarge], admin: true) }

  # ACME’s Suppliers =======================================================
  let(:buynlarge) { create(:company, purchaser: acme) }
  let(:bob)       { create(:user, from: buynlarge) }

  let(:bluthco)   { create(:company, purchaser: acme, pending: :supplier) }
  let(:barry)     { create(:user, from: bluthco, admin: true) }

  # ACME’s Purchasers ======================================================
  let(:cyberdyne) { create(:company, supplier: acme) }
  let(:carol)     { create(:user, from: cyberdyne) }

  let(:cogswell)  { create(:company, supplier: acme, pending: :supplier) }

  # Unaffiliated Companies =================================================
  let(:zorg) { create(:company) }
  let(:zack) { create(:user) }
end
