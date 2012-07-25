class Post
  include MongoMapper::EmbeddedDocument

  key :title, String
end
