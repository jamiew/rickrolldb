class AddModelUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :name, :string 
      t.column :email, :string 
      t.column :website, :string 
      t.column :avatar, :string
    end    
  end

  def self.down
    drop_table :users
  end
end
