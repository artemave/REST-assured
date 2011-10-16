class RenameMethodToVerb < ActiveRecord::Migration
  def self.up
    rename_column :doubles, :method, :verb
  end

  def self.down
    rename_column :doubles, :verb, :method
  end
end
