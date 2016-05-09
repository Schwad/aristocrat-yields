class StoreYesterdayInQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :yesterday_value, :float
  end
end
