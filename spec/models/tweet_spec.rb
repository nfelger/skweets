require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../lib/models/tweet.rb')

describe Tweet do
  subject { Tweet }
  it { should respond_to(:all) }
end

describe Tweet, :has? do
  subject { Tweet.new }

  context "without a profile_image_url" do
    it "should return false for :profile_image_url" do
      subject.has?(:profile_image_url).should be_false
    end
  end

  context "with a profile_image_url" do
    before(:each) do
      subject.profile_image_url = "http://a2.twimg.com/someimage"
    end

    it "should return true for :profile_image_url" do
      subject.has?(:profile_image_url).should be_true
    end
  end

  context "for any other property" do
    before(:each) do
      subject.class.property :some_property, String
    end

    context "when not set" do
      it "should return false" do
        subject.has?(:some_property).should be_false
      end
    end

    context "when set" do
      before(:each) do
        subject.some_property = "something"
      end

      it "should return true" do
        subject.has?(:some_property).should be_true
      end
    end
  end

  context "for a symbol which isn't a property" do
    it "should return false" do
      subject.has?(:not_a_property).should be_false
    end
  end
end
