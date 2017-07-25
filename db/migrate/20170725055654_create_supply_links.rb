class CreateSupplyLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :supply_links do |t|

      t.timestamps
    end
  end
end
