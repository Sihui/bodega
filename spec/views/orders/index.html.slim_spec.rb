require 'rails_helper'

RSpec.describe "orders/index", type: :view do
  # before(:each) do
  #   assign(:orders, [
  #     Order.create!(
  #       :supplier => nil,
  #       :purchaser => nil,
  #       :invoice => "Invoice"
  #     ),
  #     Order.create!(
  #       :supplier => nil,
  #       :purchaser => nil,
  #       :invoice => "Invoice"
  #     )
  #   ])
  # end

  it "renders a list of orders" do
    pending 'view creation'
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Invoice".to_s, :count => 2
  end
end
