#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'

class YSupportTest < Test::Unit::TestCase
  context "Object" do
    setup do
      require 'y_support/inert_recorder'
    end

    should "have #InertRecorder() constructor" do
      assert_equal InertRecorder, InertRecorder( :bull ).class
    end
  end # context Object
  
  context "InertRecorder" do
    setup do
      require 'y_support/inert_recorder'
    end

    should "InertRecorder exist and comply" do
      n = InertRecorder.new
      assert_equal [true, false], [n.present?, n.blank?]
      assert_respond_to InertRecorder.new, :arbitrary_message
      n = InertRecorder.new :x, :y
      n.arbitrary_message( :a, :b ) { "hello" }
      assert_equal [:x, :y], n.init_args
      assert_equal [ :arbitrary_message, [:a, :b] ], n.recorded_messages[0][0..1]
      assert_equal "hello", n.recorded_messages[0][2].call
    end
  end # context InertRecorder
end # class InertRecorderTest
