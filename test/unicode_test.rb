#! /usr/bin/ruby
#encoding: utf-8

require 'minitest/autorun'

describe "y_support/unicode" do
  before do
    require 'y_support/unicode'
  end

  it "should define a tiny number of Unicode aliases" do
    o = Object.new
    assert o.singleton_class == o.ⓒ
    assert o.ç == o.class
    assert 10 == Σ(1..4)
    assert 24 == Π(1..4)
    2.must_equal 4.sqrt
    3.√( 8 ).must_equal 2
    ɱ = Module.new
    ɱ.ç_variable_set :@@meaning, 42
    assert ɱ.class_variable_get( :@@meaning ) == 42
    assert ɱ.ç_variable_get( :@@meaning ) == 42
    assert ɱ.ç_variable_defined?( :@@meaning )
    ɱ.remove_ç_variable :@@meaning
    assert ! ɱ.ç_variable_defined?( :@@meaning )
    ɱ.module_exec { ★ Comparable }
    assert ɱ < Comparable
  end
end
