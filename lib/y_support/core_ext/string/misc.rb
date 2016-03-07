# encoding: utf-8

require 'active_support/core_ext/object/blank'
require 'active_support/multibyte/chars'

class String
  # Integer() style conversion, or false if conversion impossible.
  # 
  def to_Integer
    begin
      int = Integer stripn
      return int
    rescue ArgumentError
      return false
    end
  end
  
  # Float() style conversion, or false if conversion impossible.
  # 
  def to_Float
    begin
      fl = Float stripn
      return fl
    rescue ArgumentError
      return false
    end
  end
  
  # Like #strip, but also strips newlines.
  # 
  def stripn
    encode( universal_newline: true )
      .gsub("\n", "")
      .strip
  end

  # Joins a paragraph of possibly indented, newline separated lines into a
  # single contiguous string.
  # 
  def wring_heredoc
    encode(universal_newline: true)
      .split("\n")                   # split into lines
      .map( &:strip )                # strip them
      .delete_if( &:blank? )         # delete blank lines
      .join " "                      # and join with whitspace
  end

  # If the string is empty, it gets replace with the string given as argument.
  # 
  def default! default_string
    strip.empty? ? clear << default_string.to_s : self
  end

  # As it says – replaces spaces with underscores.
  # 
  def underscore_spaces
    gsub ' ', '_'
  end

  # Converts a string into a string suitable as a symbol. Although symbols can
  # be created from any strings, sometimes it is good to have symbols without
  # accented characters, punctuation and whitespaces. This method returns a
  # string of these characteristics.
  # 
  def standardize
    ς = self.dup.normalize( :kd )
    ",.;".each_char { |c| ς.gsub! c, " " }
    ς.stripn
      .squeeze(" ")
      .underscore_spaces
  end

  # Applies #standardize to the receiver and converts the result to a symbol.
  # 
  def to_standardized_sym
    standardize
      .to_sym
  end

  # Capitalizes a string and appends an exclamation mark. Also allows optional
  # argument for string interpolation. Handy for constructing error messages.
  # 
  def X! arg=nil
    arg.nil? ? capitalize + ?! : ( self % arg ).X!
  end
end
