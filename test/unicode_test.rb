#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'
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
      assert 2 == √( 4 )
      assert 10 == ∑(1..4)
      assert 10 == Σ(1..4)
      assert 24 == ∏(1..4)
      assert 24 == Π(1..4)
      ɱ = Module.new
      ɱ.ç_variable_set :@@meaning, 42
      assert ɱ.class_variable_get( :@@meaning ) == 42
      assert ɱ.ç_variable_get( :@@meaning ) == 42
      assert ɱ.ç_variable_defined?( :@@meaning )
      ɱ.remove_ç_variable :@@meaning
      assert ! ɱ.ç_variable_defined?( :@@meaning )
      ll = λ{}
      assert ll.is_a? Proc
      assert ll.lambda?
      lL = Λ{}
      assert lL.is_a? Proc
      assert ! lL.lambda?
    end
  end
end
