class AddActiveBitToFixtures < ActiveRecord::Migration[4.2]
  def self.up
    add_column :fixtures, :active, :boolean, :default => true
  end

  def self.down
    remove_column :fixtures, :active
  end
end
