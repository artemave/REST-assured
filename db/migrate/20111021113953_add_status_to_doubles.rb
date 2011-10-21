class AddStatusToDoubles < ActiveRecord::Migration
  def self.up
    add_column :doubles, :status, :integer
  end

  def self.down
    remove_column :doubles, :status
  end
end
