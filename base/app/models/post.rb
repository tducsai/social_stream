class Post < ActiveRecord::Base
  include SocialStream::Models::Object

  alias_attribute :text, :description
  validates_presence_of :text

  def title
    description.truncate(30, :separator =>' ')
  end
end
