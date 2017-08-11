require 'rails_helper'

RSpec.describe "orders/new", type: :view do
  before(:each) do
    assign(:order, Order.new(
      :supplier => nil,
      :purchaser => nil,
      :invoice => "MyString"
    ))
  end

  it "renders new order form" do
    pending 'view creation'
    render

    assert_select "form[action=?][method=?]", orders_path, "post" do

      assert_select "input[name=?]", "order[supplier_id]"

      assert_select "input[name=?]", "order[purchaser_id]"

      assert_select "input[name=?]", "order[invoice]"
    end
  end
end
