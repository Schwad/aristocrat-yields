class PimpsOutQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :day_change, :float
    add_column :quotes, :best_rate, :float
  end
end
