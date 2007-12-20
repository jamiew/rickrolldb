class AddModelEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.column :title, :string 
      t.column :url, :string 
      t.column :thumbnail, :string
      t.column :user_id, :integer 
      t.column :created_at, :datetime 
      t.column :updated_at, :datetime 
    end    
  end

  def self.down
    drop_table :entries
  end
end
