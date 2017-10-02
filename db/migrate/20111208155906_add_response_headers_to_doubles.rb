class AddResponseHeadersToDoubles < ActiveRecord::Migration[4.2]
  def self.up
    add_column :doubles, :response_headers, :string
  end

  def self.down
    remove_column :doubles, :response_headers
  end
end
