class RenameFixturesToDoubles < ActiveRecord::Migration
  def self.up
    rename_table :fixtures, :doubles
  end

  def self.down
    rename_table :doubles, :fixtures
  end
end
