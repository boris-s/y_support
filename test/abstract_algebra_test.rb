#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'

class AbstractAlgebraTest < Test::Unit::TestCase
  context "Matrix" do
    setup do
      require 'y_support/abstract_algebra'
    end

    should "define Monoid" do
      klass = Class.new( Algebra::Monoid )
      m = klass.new
      assert m + klass.zero == m
      assert m == m + klass.zero
      assert klass.zero + m == m
      assert m == klass.zero + m
    end
  end # context Matrix
end # class AbstractAlgebraTest
