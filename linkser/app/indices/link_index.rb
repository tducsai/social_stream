ThinkingSphinx::Index.define :link, :with => :active_record do
  activity_object_index

  indexes url
end
