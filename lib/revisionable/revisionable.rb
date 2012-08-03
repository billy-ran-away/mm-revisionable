module Revisionable
  extend ActiveSupport::Concern

  def create_new_revision
    unless revisions.current.try(:attributes).try(:except, :version_id).to_json == attributes.except(:version_id).to_json
      update_attribute :version, revisions.create(:saved_at => updated_at, :data => attributes)
      version.update_attribute :data, attributes

      if self.class.revision_limits
        revisions.first.delete if revisions.count > self.class.revision_limits
      end
    end
  end

  def tag_with(tag)
    revisions.find(version_id).update_attribute :tag, tag
  end

  included do
    timestamps!

    belongs_to :version, :class_name => "Revision"
    many :revisions, :as => :revisionable do
      def tagged(tag)
        first(:tag => tag).try :record
      end

      def current
        sort(:saved_at).last.try :record
      end

      def at(point)
        if point.is_a? Date
          first(:saved_at => point).try :record
        elsif point.is_a? Symbol
          case point
          when :current
            sort(:saved_at).last.try :record
          when :first
            sort(:saved_at).first.try :record
          when :last
            sort(:saved_at).all[sort(:saved_at).all.index(proxy_owner.version) - 1].try :record
          end
        elsif point.is_a? Integer
          sort(:saved_at)[point].try :record
        end
      end
    end

    after_save :create_new_revision
  end

  module ClassMethods
    def revision_limits
      @revision_limits
    end

    def limit_revisions_to(number_of_revisions)
      @revision_limits = number_of_revisions
    end
  end
end
