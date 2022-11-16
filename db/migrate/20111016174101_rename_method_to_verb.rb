class RenameMethodToVerb < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :doubles, :method, :verb
  end

  def self.down
    rename_column :doubles, :verb, :method
  end
end
