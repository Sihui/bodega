require 'rails_helper'

RSpec.describe "orders/show", type: :view do
  # before(:each) do
  #   @order = assign(:order, Order.create!(
  #     :supplier => nil,
  #     :purchaser => nil,
  #     :invoice => "Invoice"
  #   ))
  # end

  it "renders attributes in <p>" do
    pending 'view creation'
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Invoice/)
  end
end
