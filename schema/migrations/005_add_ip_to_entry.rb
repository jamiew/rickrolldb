class AddIpToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :ip, :string
  end

  def self.down
    drop_column :entries, :ip
  end
end
