# encoding: utf-8
puts "Hello from #{File.basename(__FILE__)}"

require 'y_support'

# +y_support/unicode+ defines a small number of Unicode 1-character aliases to
# make code more concise.
#
# * <b>ç</b> – class (c with cedilla, U00E7)
# * <b>ⓒ</b> – singleton class (copyright sign)
# * <b>√</b> – square root
# * <b>Σ</b> – summation
# * <b>Π</b> – product
#
class Object
  alias :ç :class
  alias ⓒ singleton_class

  # Sum. The argument is expected to be a collection; block can be specified.
  # Basically same as chaining .reduce( :+ ) to the end; Σ() notation can be
  # more readable at times.
  # 
  def Σ( collection )
    collection.reduce { |acc, element|
      acc + ( block_given? ? yield( element ) : element )
    }
  end

  # Product. The argument is expected to be a collection; block can be specified.
  # Basically same as chaining .reduce( :* ) to the end; Π() notation can be
  # more readable at times.
  # 
  def Π( collection )
    collection.reduce { |acc, element|
      acc * ( block_given? ? yield( element ) : element )
    }
  end
end

# +y_support/unicode+ also defines the following aliases:
# 
# * <b>★</b> – alias for include
# * <b>ç</b> for +class+ in several method names
# 
class Module
  alias ★ include
  
  alias ç_variable_set class_variable_set
  alias ç_variable_get class_variable_get
  alias ç_variable_defined? class_variable_defined?
  alias remove_ç_variable remove_class_variable
end

# Defined aliases
# 
# * <b>√</b> – root of arbitrary degree ( x.√( n ) is n ** ( 1 / x ) ).
# * <b>sqrt</b> as in +4.sqrt+ for square root (Math#sqrt).
#
class Numeric
  # Returns n-th root of the argument, where n is the receiver number.
  # 
  def √ number
    number ** ( 1.0 / self )
  end

  # Square root (using Math#sqrt).
  # 
  def sqrt
    Math.sqrt( self )
  end
end

# Other abbreviations (eg. for local variables) are optionally encouraged:
# 
# * <b>ɱ</b> – module (m with hook, U2C6E, compose seq. [m, j])
# * <b>ꜧ</b> – hash (latin small letter heng, UA727, compose seq. [h, j])
# * <b>ᴀ</b> – array (small capital A, U1D00, compose seq. [a, `])
# * <b>ß</b> – symbol (German sharp s, U00DF, compose seq. [s, s])
# * <b>ς</b> – string (Greek final sigma, U03C2, compose seq. [*, w])
# * <b>w</b> – abbreviation for "with"
# * <b>wo</b> – abbreviation for "without"
# 
# Note on compose sequences:
# 
# Each compose sequence is preceded the <compose> key, whose location depends
# on your system configuration. The sequences above comply with the standard
# Kragen's .XCompose file (https://github.com/kragen/xcompose). In some cases,
# the characters not in Kragen's file have to be defined manually for
# comfortable typing.
