class AddModelComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column :entry_id, :integer 
      t.column :user_id, :integer 
      t.column :body, :text 
    end    
  end

  def self.down
    drop_table :comments
  end
end
