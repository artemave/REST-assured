class AddResponseHeadersToDoubles < ActiveRecord::Migration
  def self.up
    add_column :doubles, :response_headers, :string
  end

  def self.down
    remove_column :doubles, :response_headers
  end
end
