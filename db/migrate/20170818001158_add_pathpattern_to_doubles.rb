class AddPathpatternToDoubles < ActiveRecord::Migration
  def self.up
    add_column :doubles, :pathpattern, :text
  end

  def self.down
    remove_column :doubles, :text
  end
end
