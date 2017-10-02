class AddDelayToDoubles < ActiveRecord::Migration[4.2]
  def self.up
    add_column :doubles, :delay, :integer
  end

  def self.down
    remove_column :doubles, :delay
  end
end
