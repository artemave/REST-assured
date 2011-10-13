class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.integer :double_id
      t.string :body
      t.string :headers
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :requests
  end
end
