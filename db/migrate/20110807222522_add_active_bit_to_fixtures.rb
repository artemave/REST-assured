class AddActiveBitToFixtures < ActiveRecord::Migration
  def self.up
    add_column :fixtures, :active, :boolean
  end

  def self.down
    remove_column :fixtures, :active
  end
end
