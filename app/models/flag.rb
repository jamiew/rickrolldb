class Flag < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user
end