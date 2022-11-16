class CreateRequests < ActiveRecord::Migration[4.2]
  def self.up
    create_table :requests do |t|
      t.integer :double_id
      t.text :params
      t.text :body
      t.text :rack_env
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :requests
  end
end
