class AddExtrasOneOffToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :extras_one_off, :boolean, default: true
  end
end
