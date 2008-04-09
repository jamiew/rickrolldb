class AddStatusToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :status, :string, :default => 'pending'
    add_index :entries, :status
  end

  def self.down
#    remove_column :entries, :status
#    remove_index :entries, :status
  end
end
