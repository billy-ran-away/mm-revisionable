require 'spec_helper'

describe Revisionable do
  before :each do
    @user = User.create(:name => 'Silky Johnston')
  end

  describe 'revisioning' do
    it 'should have one revision on creation' do
      @user.revisions.count.should equal 1
    end

    it 'should have a new revision after update attribute' do
      expect{ @user.update_attribute :name, 'Buck Nasty' }.to change{ @user.revisions.count }.by(1)
    end

    it 'should have a new revision after update_attributes' do
      expect{ @user.update_attributes :name => 'Buck Nasty' }.to change{ @user.revisions.count }.by(1)
    end

    it 'should have a new revision after save' do
      @user.name = 'Buck Nasty'

      expect{ @user.save }.to change{ @user.revisions.count }.by(1)
    end

    it 'should have its first revision accessible' do
      @user.update_attribute :name, 'Buck Nasty'

      @user.revisions.at(:first).name.should == 'Silky Johnston'
    end

    it 'should have its last revision accessible' do
      @user.update_attribute :name, 'Buck Nasty'
      @user.update_attribute :name, 'Leonard Washington'

      @user.revisions.at(:last).name.should == 'Buck Nasty'
    end

    it 'should have its current revision accessible' do
      @user.update_attribute :name, 'Buck Nasty'
      @user.update_attribute :name, 'Leonard Washington'

      @user.revisions.at(:current).name.should == 'Leonard Washington'
    end

    it 'should only create a new revision when its data changes' do
      expect{ @user.save }.not_to change{ @user.revisions.count }
    end

    it 'should allow specific revisions to be tagged' do
      @user.update_attributes :name => 'Buck Nasty'
      @user.revisions.current.tag_with "1.0"
      @user.update_attributes :name => 'Leonard Washington'
      @user.revisions.current.tag_with "1.1"

      @user.revisions.tagged("1.0").name.should == 'Buck Nasty'
      @user.revisions.tagged("1.1").name.should == 'Leonard Washington'
    end

    it 'should limit revisions' do
      class ModifiedUser < User
        limit_revisions_to 2
      end

      modified_user = ModifiedUser.create(:name => 'Joe Schmoe')
      modified_user.update_attributes :name => 'Leonard Washington'

      modified_user.revisions.count.should == 2

      modified_user.update_attributes :name => 'Buck Nasty'

      modified_user.revisions.count.should == 2
    end
  end

  describe 'revisioning of embedded documents' do
    before :each do
      @user.posts << Post.new(:title => "Upcoming Playa Hater's Ball")
      @user.save
    end

    it 'should create a parent revision when embedded document changes' do
      expect { @user.posts.first.update_attribute :title, "Upcoming Playa Hata's Ball" }.to change { @user.revisions.count }.by(1)
    end
  end
end
