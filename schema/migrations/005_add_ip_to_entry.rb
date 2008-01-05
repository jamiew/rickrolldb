class AddIpToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :ip, :string
    add_column :flags, :ip, :string
  end

  def self.down
    remove_column :entries, :ip
    remove_column :flags, :ip
  end
end
