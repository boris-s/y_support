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
      assert_equal [[], "<NullObject>", 0.0, 0], [n.to_a, n.to_s, n.to_f, n.to_i]
      assert_equal [false, true], [n.present?, n.empty?]
      assert_nothing_raised { NullObject.new.
        must_have_attr_reader( :recorded_messages ) }
      assert_respond_to NullObject.new, :arbitrary_message
      n = NullObject.new :x
      n.arbitrary_message( :a, :b ) { "hello" }
      assert_equal :x, n.null_object_signature
      assert_equal "<NullObject kokotina>", NullObject.new( :kokotina ).inspect
    end
    
  #   should "InertRecorder exist and comply" do
  #     assert defined? InertRecorder
  #     assert_equal Class, InertRecorder.class
  #     n = InertRecorder.new
  #     assert_equal [true, false], [n.present?, n.blank?]
  #     assert_nothing_raised { InertRecorder.new.
  #       must_have_attr_reader( :recorded_messages ).
  #       must_have_attr_reader( :init_args ) }
  #     assert_respond_to InertRecorder.new, :arbitrary_message
  #     n = InertRecorder.new :x, :y
  #     n.arbitrary_message( :a, :b ) { "hello" }
  #     assert_equal [:x, :y], n.init_args
  #     assert_equal [ :arbitrary_message, [:a, :b] ], n.recorded_messages[0][0..1]
  #     assert_equal "hello", n.recorded_messages[0][2].call
  #   end
    
  #   should "LocalObject exist and comply" do
  #     assert defined? LocalObject
  #     assert_equal Class, LocalObject.class
  #     n = ℒ( 'this msg' )
  #     assert_equal 'this msg', n.signature
  #     assert_equal 'this msg', n.σ
  #   end
  end # context NullObject
end # class NullObjectTest
