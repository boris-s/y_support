#encoding: utf-8

require 'y_support'

# This library sets forth 4 standard abbreviations of Ruby keywords:
#
# * <b>ç</b> – class (c with cedilla, U00E7, compose seq. [c, comma])
# * <b>ⓒ</b> – singleton class (copyright sign, U00A9, compose seq. [(, c, )])
# * <b>λ</b> – lambda (Greek character lambda)
# * <b>Λ</b> – proc (Greek character capital lambda)
#
# It is also encouraged that other on-letter Unicode abbreviations are
# used especially for local variables:
# 
# * <b>ɱ</b> – module (m with hook, U2C6E, compose seq. [m, j])
# * <b>ꜧ</b> – hash (latin small letter heng, UA727, compose seq. [h, j])
# * <b>ᴀ</b> – array (small capital A, U1D00, compose seq. [a, `])
# * <b>ß</b> – symbol (German sharp s, U00DF, compose seq. [s, s])
# * <b>ς</b> – string (Greek final sigma, U03C2, compose seq. [*, w])
# * <b>w</b> – abbreviation for "with"
# * <b>wo</b> – abbreviation for "without"
# 
# There are, however, no defined methods using these in YSupport. In other
# words, using these additional abbreviations is completely up to the goodwill
# of the developer.
#
# ==== Note on compose sequences
# 
# Each compose sequence has to be preceded by pressing the <compose> key.
# The compose sequences comply with the standard Kragen's .XCompose file
# (https://github.com/kragen/xcompose). In some cases, the needed characters
# are not in Kragen's file and need to be defined manually.
# 
class Object
  alias :ç :class
  alias :ⓒ :singleton_class
  alias :© :singleton_class

  # Square root (proxy for Math.sqrt(x)).
  # 
  def √( number ); Math.sqrt( number ) end

  # Sum. The argument is expected to be a collection; block can be specified.
  # Basically same as chaining .reduce( :+ ) to the end; Σ() notation can be
  # more readable at times.
  # 
  def ∑( collection )
    collection.reduce { |acc, element|
      acc + ( block_given? ? yield( element ) : element )
    }
  end
  alias :Σ :∑

  # Product. The argument is expected to be a collection; block can be specified.
  # Basically same as chaining .reduce( :* ) to the end; Π() notation can be
  # more readable at times.
  # 
  def ∏( collection )
    collection.reduce { |acc, element|
      acc * ( block_given? ? yield( element ) : element )
    }
  end
  alias :Π :∏
end

class Module
  alias :ç_variable_set :class_variable_set
  alias :ç_variable_get :class_variable_get
  alias :ç_variable_defined? :class_variable_defined?
  alias :remove_ç_variable :remove_class_variable
end
