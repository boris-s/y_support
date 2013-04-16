#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'

class NullObjectTest < Test::Unit::TestCase
  context 'Object' do
    setup do
      require 'y_support/null_object'
    end

    should "Object have #null_object? (alias #null?)" do
      require 'y_support/null_object'
      assert_equal true, (class Koko < NullObject; self end).new.null_object?
      assert_equal true, (class Koko < NullObject; self end).new.null?
      assert_equal [false, false], [nil.null_object?, nil.null?]
      assert_equal true, NullObject.new( :koko ).null?( :koko )
      assert_equal false, NullObject.new( :koko ).null?( :pipi )
    end

    should "Object have #Maybe() constructor for something / NullObject" do
      assert_equal NullObject, Maybe(nil).class
      assert_equal 42, Maybe(42)
    end
    
    should "Object have #Null() constructor always returning NullObject" do
      assert_equal NullObject, Null().class
    end
  end # context Object
  
  context "NullObject" do
    setup do
      require 'y_support/null_object'
    end

    should "NullObject exist and comply" do
      n = NullObject.new
      assert_equal [[], "#<NullObject>", 0.0, 0], [n.to_a, n.to_s, n.to_f, n.to_i]
      assert_equal [false, true], [n.present?, n.empty?]
      assert_nothing_raised { NullObject.new.
        must_have_attr_reader( :recorded_messages ) }
      assert_respond_to NullObject.new, :arbitrary_message
      n = NullObject.new :x
      n.arbitrary_message( :a, :b ) { "hello" }
      assert_equal :x, n.null_object_signature
      assert_equal "#<NullObject kokotina>", NullObject.new( :kokotina ).inspect
    end
  end # context NullObject
end # class NullObjectTest
