#! /usr/bin/ruby
#encoding: utf-8

require 'minitest/autorun'

describe "LocalObject" do
  before do
    require './../lib/y_support/local_object'
  end

  describe "Object" do
    it "should have constructor #LocalObject, alias #L!" do
      assert_equal LocalObject, LocalObject().class
      assert_equal LocalObject, L!.class
    end

    it "should have #local_object?, alias #ℓ?" do
      assert_equal false, Object.new.local_object?
      assert_equal false, Object.new.ℓ?
    end
  end
  
  describe "LocalObject" do
    it "should exist and comply" do
      n = LocalObject.new 'whatever'
      assert ! n.ℓ?
      assert n.ℓ? 'whatever'
      assert_equal 'whatever', n.signature
      assert_equal 'whatever', n.σ
    end
  end
end
