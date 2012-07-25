class User
  include MongoMapper::Document
  plugin Revisionable
  limit_revisions_to 20

  key :name, String

  many :posts
end
