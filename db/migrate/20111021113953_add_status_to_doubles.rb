class AddStatusToDoubles < ActiveRecord::Migration[4.2]
  def self.up
    add_column :doubles, :status, :integer
  end

  def self.down
    remove_column :doubles, :status
  end
end
