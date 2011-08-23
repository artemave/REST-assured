class AddMethodToFixtures < ActiveRecord::Migration
  def self.up
    add_column :fixtures, :method, :string
  end

  def self.down
    remove_column :fixtures, :method
  end
end
