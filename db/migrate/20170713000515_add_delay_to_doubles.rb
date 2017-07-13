class AddDelayToDoubles < ActiveRecord::Migration
  def self.up
    add_column :doubles, :delay, :integer
  end

  def self.down
    remove_column :doubles, :delay
  end
end
