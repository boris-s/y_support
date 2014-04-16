#! /usr/bin/ruby
# encoding: utf-8

require 'minitest/autorun'

describe "InertRecorder"  do
  before do
    require './../lib/y_support/inert_recorder'
  end

  describe "Object" do
    it "should have #InertRecorder() constructor" do
      assert_equal InertRecorder, InertRecorder( :bull ).class
    end
  end
  
  describe "InertRecorder" do
    it "should InertRecorder exist and comply" do
      n = InertRecorder.new
      assert_equal [true, false], [n.present?, n.blank?]
      assert_respond_to InertRecorder.new, :arbitrary_message
      n = InertRecorder.new :x, :y
      n.arbitrary_message( :a, :b ) { "hello" }
      assert_equal [:x, :y], n.init_args
      assert_equal [ :arbitrary_message, [:a, :b] ], n.recorded_messages[0][0..1]
      assert_equal "hello", n.recorded_messages[0][2].call
    end
  end
end
