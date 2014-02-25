class TestObject < ActiveRecord::Base
  validates :subject, uniqueness: true
end
