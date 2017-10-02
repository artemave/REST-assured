class ChangeFullpathToText < ActiveRecord::Migration[4.2]
  def self.up
    change_column :doubles, :fullpath, :text
  end

  def self.down
    change_column :doubles, :fullpath, :string
  end
end
