require 'test_helper'

class VersioningTest < Test::Unit::TestCase
  context 'revision manipulations' do
    setup do
      @user = User.create(:name => 'Silky Johnston')
    end

    should 'have one revision on creation' do
      assert_equal 1, @user.revisions.count, "Doesn't have just one revision after creation"
    end

    should 'have a new revision after update_attribute' do
      original_revision_count = @user.revisions.count
      @user.update_attribute :name, 'Buck Nasty'

      assert_equal original_revision_count + 1, @user.revisions.count, "Didn't create a revision after update_attribute"
    end

    should 'have a new revision after update_attributes' do
      original_revision_count = @user.revisions.count
      @user.update_attributes :name => 'Buck Nasty'

      assert_equal original_revision_count + 1, @user.revisions.count, "Didn't create a revision after update_attributes"
    end

    should 'have a new revision after save' do
      original_revision_count = @user.revisions.count
      @user.name = 'Buck Nasty'
      @user.save

      assert_equal original_revision_count + 1, @user.revisions.count, "Didn't create a revision after update_attributes"
    end

    should 'have its first revision accessible' do
      @user.update_attribute :name, 'Buck Nasty'

      assert_equal 'Silky Johnston', @user.revisions.at(:first).name, "First revision didn't return the first version"
    end

    should 'have its last revision accessible' do
      @user.update_attribute :name, 'Buck Nasty'
      @user.update_attribute :name, 'Leonard Washington'

      assert_equal 'Buck Nasty', @user.revisions.at(:last).name, "Last revision didn't return the last version"
    end

    should 'have its current revision accessible' do
      @user.update_attribute :name, 'Buck Nasty'
      @user.update_attribute :name, 'Leonard Washington'

      assert_equal 'Leonard Washington', @user.revisions.at(:current).name, "Current revision didn't return the current version"
    end

    should 'only create a new revision when the data changes' do
      revisions_count = @user.revisions.count
      @user.save
      assert_equal revisions_count, @user.revisions.count
    end

    should "allow specific versions to be tagged" do
      @user.update_attributes :name => 'Buck Nasty'
      @user.revisions.current.tag_with "1.0"
      @user.update_attributes :name => 'Leonard Washington'
      @user.revisions.current.tag_with "1.1"

      assert_equal 'Buck Nasty', @user.revisions.tagged("1.0").name
      assert_equal 'Leonard Washington', @user.revisions.tagged("1.1").name
    end
  end
end
