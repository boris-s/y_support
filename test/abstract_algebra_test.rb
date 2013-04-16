#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'

class AbstractAlgebraTest < Test::Unit::TestCase
  context "Algebra" do
    setup do
      require 'y_support/abstract_algebra'
      # Define the stupidest monoid:
      @monoid = Class.new { include Algebra::Monoid } # make some class
      zero = @monoid.new         # call arbitrary instance zero
      @monoid.class_exec {
        # Define the stupidest #add method.
        define_method :add do |other|
          if self == zero then other
          elsif other == zero then self
          else self.class.addition_table[[self, other]] end
        end
        # Define the stupidest addition table.
        instance_variable_set :@addition_table,                      
                              Hash.new { |ꜧ, k|
                                ꜧ[k] = if k[0].object_id <= k[1].object_id
                                         new # just make up an instance
                                       else
                                         ꜧ[k[1], k[0]] # swap operands
                                       end
                              }
      }
      # And refine the @monoid's singleton class.
      @monoid.singleton_class.class_exec { attr_reader :addition_table }
      @monoid.define_singleton_method :additive_identity do zero end
    end

    should "have working Monoid" do
      m = @monoid.random                  # choose an instance

      # #== method
      assert m == m

      # closure
      # (not tested)

      # associativity
      n, o = @monoid.random, @monoid.random
      assert ( m + n ) + o == m + ( n + o )

      # identity element
      assert m + @monoid.zero == m
      assert @monoid.zero + m == m
    end

    should "have working Group" do
      g = @group.random

      # (monoid properties not tested)

      # inverse element
      assert g + (-g) == @group.zero
      assert (-g) + g == @group.zero
    end

    should "define AbelianGroup" do
      ag = @abelian_group.random

      # (group properties not tested)

      # commutativity
      bh = @abelian_group.random
      assert ag + bh == bh + ag
    end

    should "define Ring" do
      r = @ring.random

      # (abelian group properties with respect to addition not tested)

      # (multiplication closure not tested)

      # multiplication associativity
      s, t = @ring.random, @ring.random
      assert r * ( s * t ) == ( r * s ) * t

      # multiplication identity
      mi = @ring.one
      assert r * mi == r
      assert mi * r == r

      # distributivity
      assert r * ( s + t ) == ( r * s ) + ( s * t )
    end

    should "define Field" do
      f = @field.random

      # (ring properties not tested)
      
      # multiplicative inverse
      mi = @ring.multiplicative_identity
      assert f * f.multiplicative_inverse == mi
      assert f.multiplicative_inverse * f == mi
    end
  end

  context "numerics" do
    setup do
      require 'y_support/abstract_algebra'
    end

    should "have patched Integer" do
      assert Integer.zero.equal? 0
    end

    should "have patched Float" do
      assert Float.zero.equal? 0.0
    end

    should "have patched Rational" do
      assert Rational.zero.equal? Rational( 0, 0 )
    end

    should "have patched Complex" do
      assert Complex.zero.equal? Complex( 0, 0 )
    end
  end

  context "Matrix" do
    setup do
      require 'y_support/abstract_algebra'
    end

    should "have Matrix.wildcard_zero public instance method" do
      # FIXME
    end

    should "be able to perform #* with nonnumerics in the matrix" do
      # FIXME
    end

    should "numeric matrix multiplication still be working normally" do
      # FIXME
    end
  end # context Matrix
end # class AbstractAlgebraTest
