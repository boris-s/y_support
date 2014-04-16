#encoding: utf-8

require 'y_support'
require 'y_support/null_object'

# Rudiments of abstract algebra in Ruby.
#
# Some objects (users, mixins...) might ask from other classes to have things
# defined such as operators #+, #*, or to have a specific instance that behaves
# additive identity element (ie. zero), or multiplicative identity element (ie.
# one). The essence of some of these requirements is captured by the abstract
# algebraic notions of magma, monoid, ring, field...
#
# At the moment being, y_support/abstract_algebra does not aim as high as to
# comprehensively support monoids, rings, fields and the plethora of abstract
# algebraic stuff. Support is provided to such degree, as to make some practical
# problems tractable. (Our original concern was with Matrix instances filled
# with non-numeric objects, whose #+ operator was not coercible to work with
# numerics.)
# 

# Adds abstract algebra concepts to Ruby.
#
module Algebra
  # A Monoid requires:
  #
  # Closed and associative addition: #add method
  # Additive identity element: #additive_identity
  # 
  module Monoid
    def self.included receiver
      receiver.extend self::ClassMethods
    end

    def + summand; add summand end

    module ClassMethods
      def zero; additive_identity end
    end
  end

  # A group is a monoid with additive inverse.
  #
  # additive inversion: #additive_inverse
  # 
  module Group
    include Monoid
    def -@; additive_inverse end
    def - subtrahend; add subtrahend.additive_inverse end
  end

  # A group that fulfills the condition of commutativity
  #
  # ( a.add b == b.add a ).
  # 
  module AbelianGroup
    include Group
  end

  # A ring is a commutative group with multiplication.
  # 
  # multiplication: #multiply (associative, distributive)
  # multiplicative identity element: #multiplicative_identity
  # 
  module Ring
    include AbelianGroup
    def * multiplicand; multiply multiplicand end
    def one; multiplicative_identity end
  end

  # A field is a ring that can do division.
  # 
  module Field
    include Ring
    def inverse; multiplicative_inverse end
    def / divisor; multiply divisor.multiplicative_inverse end
  end
end


# Patching Integer with Algebra::Ring compliance methods.
# 
class << Integer
  def additive_identity; 0 end
  alias zero additive_identity
  def add( other ); self + other end
  def additive_inverse; -self end
  def multiply( other ); self * other end
  def multiplicative_identity; 1 end
  alias one multiplicative_identity
end

# Patching Float with Algebra::Field compliance methods.
# 
class << Float
  def additive_identity; 0.0 end
  alias zero additive_identity
  def add( other ); self + other end
  def additive_inverse; -self end
  def multiply( other ); self * other end
  def multiplicative_identity; 1.0 end
  alias one multiplicative_identity
  def multiplicative_inverse; 1.0 / self end
end

# Patching Rational with Algebra::Field compliance methods.
# 
class << Rational
  def additive_identity; Rational 0, 1 end
  alias zero additive_identity
  def add( other ); self + other end
  def additive_inverse; -self end
  def multiply( other ); self * other end
  def multiplicative_identity; Rational 1, 1 end
  alias one multiplicative_identity
  def multiplicative_inverse; Rational( 1, 1 ) / self end
end

# Patching Complex with #zero method.
# 
class << Complex
  def additive_identity; Complex 0.0, 0.0 end
  alias zero additive_identity
  def add( other ); self + other end
  def additive_inverse; -self end
  def multiply( other ); self * other end
  def multiplicative_identity; Complex 1, 0 end
  alias one multiplicative_identity
  def multiplicative_inverse; Complex( 1, 0 ) / self end
end



# Wildcard zero, stronger than ordinary numeric literal 0.
# 
( WILDCARD_ZERO = NullObject.new ).instance_exec {
  ɪ = self
  singleton_class.class_exec { define_method :zero do ɪ end }
  def * other; other.class.zero end
  def / other
    self unless other.zero?
    fail ZeroDivisionError, "The divisor is zero! (#{other})"
  end
  def + other; other end
  def - other; -other end
  def coerce other; return other, other.class.zero end
  def zero?; true end
  def to_s; "∅" end
  def inspect; to_s end
  def to_f; 0.0 end
  def to_i; 0 end
  def == other
    z = begin
          other.class.zero
        rescue NoMethodError
          return false
        end
    other == z
  end
}


# As a matter of fact, current version of the Matrix class (by Marc-Andre
# Lafortune) does not work with physical magnitudes. It is a feature of the
# physical magnitudes, that they do not allow themselves summed with plain
# numbers or incompatible magnitudes. But current version of Matrix class,
# upon matrix multiplication, performs needless addition of the matrix elements
# to literal numeric 0.
#
# The obvious solution is to patch Matrix class so that the needless addition
# to literal 0 is no longer performed.
#
# More systematically, abstract algebra is to be added to Ruby, and Matrix is
# to require that its elements comply with monoid, group, ring, field, depending
# on the operation one wants to do with such matrices.
#
class Matrix
  attr_writer :zero
  
  def zero
    if empty? then @zero else self[0, 0] * 0 end
  end

  # Matrix multiplication.
  #
  def * arg # arg is matrix or vector or number
    case arg
    when Numeric
      rows = @rows.map { |row| row.map { |e| e * arg } }
      return new_matrix rows, column_size
    when Vector
      arg = Matrix.column_vector arg
      result = self * arg
      return result.column 0
    when Matrix
      Matrix.Raise ErrDimensionMismatch if column_size != arg.row_size
      if empty? then # if empty?, then reduce uses WILDCARD_ZERO
        rows = Array.new row_size do |i|
          Array.new arg.column_size do |j|
            ( 0...column_size ).reduce WILDCARD_ZERO do |sum, c|
              sum + arg[c, j] * self[i, c]
            end
          end
        end
      else             # if non-empty, reduce proceeds without WILDCARD_ZERO
        rows = Array.new row_size do |i|
          Array.new arg.column_size do |j|
            ( 0...column_size ).map { |c| arg[c, j] * self[i, c] }.reduce :+
          end
        end
      end
      return new_matrix( rows, arg.column_size )
    when ( SY::Magnitude rescue :SY_Magnitude_absent ) # newly added - multiplication by a magnitude
      # I am not happy with this explicit switch on SY::Magnitude type here.
      # Perhaps coerce should handle this?
      rows = Array.new row_size do |i|
        Array.new column_size do |j|
          self[i, j] * arg
        end
      end
      return self.class[ *rows ]
    else
      compat_1, compat_2 = arg.coerce self
      return compat_1 * compat_2
    end
  end

  # Creates a matrix of prescribed dimensions filled with wildcard zeros.
  # 
  def Matrix.wildcard_zero r_count, c_count=r_count
    build r_count, c_count do |r, c| WILDCARD_ZERO end
  end
end

