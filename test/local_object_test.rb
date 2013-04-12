#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'

class LocalObjectTest < Test::Unit::TestCase
  context "Object" do
    setup do
      require 'y_support/local_object'
    end

    should "have constructor #LocalObject, alias #L!" do
      assert_equal LocalObject, LocalObject().class
      assert_equal LocalObject, L!.class
    end

    should "have #local_object?, alias #ℓ?" do
      assert_equal false, Object.new.local_object?
      assert_equal false, Object.new.ℓ?
    end
  end # context Object
  
  context "LocalObject" do
    setup do
      require 'y_support/local_object'
    end

    should "exist and comply" do
      n = LocalObject.new 'whatever'
      assert ! n.ℓ?
      assert n.ℓ? 'whatever'
      assert_equal 'whatever', n.signature
      assert_equal 'whatever', n.σ
    end
  end # context LocalObject
end # class LocalObjectTest
