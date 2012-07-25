class Revision
  include MongoMapper::Document

  key :data, Hash
  key :saved_at, Time
  key :message, String
  key :updater_id, String
  key :tag, String

  belongs_to :revisionable, :polymorphic => true

  def record
    revisionable.tap { |object| object.attributes = data }
  end

  def content(key)
    cdata = self.data[key]
    if cdata.respond_to?(:join)
      cdata.join(" ")
    else
      cdata
    end
  end
end
