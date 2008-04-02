class AddIndicesToEntries < ActiveRecord::Migration
  def self.up
    add_index(:entries, :created_at)    
    add_index(:entries, :updated_at)
  end

  def self.down
    remove_index(:entries, :created_at)
    remove_index(:entries, :created_at)
  end
end
