#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'
require 'minitest/spec'
require 'minitest/autorun'
# require 'y_support/all'

class UnicodeTest < Test::Unit::TestCase
  context "Object" do
    setup do
      require 'y_support/unicode'
    end

    should "have a very limited number of one-character Unicode aliases" do
      ◉ = Object.new
      assert ◉.singleton_class == ◉.©
      assert ◉.singleton_class == ◉.ⓒ
      assert ◉.ç == ◉.class
      assert_equal 2, √( 4 )
      assert equal 10, ∑(1..4)
      assert_equal 10, Σ(1..4)
      # ∏ alias Π
      # ç_variable_set
      # ç_variable_get
      # ç_variable_defined?
      # remove_ç_variable
      # λ
      # Λ
    end
  end
end
