class User < ActiveRecord::Base
  has_many :entries
  has_many :comments
  has_many :flags
  
  def to_s
    name
  end
end