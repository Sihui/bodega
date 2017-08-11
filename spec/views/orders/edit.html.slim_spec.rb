require 'rails_helper'

RSpec.describe "orders/edit", type: :view do
  # before(:each) do
  #   @order = assign(:order, Order.create!(
  #     :supplier => nil,
  #     :purchaser => nil,
  #     :invoice => "MyString"
  #   ))
  # end

  it "renders the edit order form" do
    pending 'view creation'
    render

    assert_select "form[action=?][method=?]", order_path(@order), "post" do

      assert_select "input[name=?]", "order[supplier_id]"

      assert_select "input[name=?]", "order[purchaser_id]"

      assert_select "input[name=?]", "order[invoice]"
    end
  end
end
