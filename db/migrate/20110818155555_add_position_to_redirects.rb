class AddPositionToRedirects < ActiveRecord::Migration[4.2]
  def self.up
    add_column :redirects, :position, :integer
  end

  def self.down
    remove_column :redirects, :position
  end
end
