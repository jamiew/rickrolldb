class AddModelFlags < ActiveRecord::Migration
  def self.up
    create_table :flags do |t|    
      t.column :entry_id, :integer 
      t.column :user_id, :integer 
      t.column :name, :string
      t.column :value, :string
    end
  end

  def self.down
    drop_table :flags
  end
end
