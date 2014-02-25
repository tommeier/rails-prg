class ErrorDuplicator < ActiveRecord::Base
  validates :subject, uniqueness: true, presence: true
end
