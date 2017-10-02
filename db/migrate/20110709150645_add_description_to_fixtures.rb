class AddDescriptionToFixtures < ActiveRecord::Migration[4.2]
  def self.up
    add_column :fixtures, :description, :text
  end

  def self.down
    remove_column :fixtures, :description
  end
end
