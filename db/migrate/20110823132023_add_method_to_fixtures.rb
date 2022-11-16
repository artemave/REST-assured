class AddMethodToFixtures < ActiveRecord::Migration[4.2]
  def self.up
    add_column :fixtures, :method, :string
  end

  def self.down
    remove_column :fixtures, :method
  end
end
