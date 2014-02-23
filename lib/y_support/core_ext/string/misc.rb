#encoding: utf-8

require 'active_support/core_ext/object/blank'

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

  # Converts a string into a standard symbol. While Symbol class objects can
  # be created from any string, it is good practice to keep symbols free of
  # whitespaces and weird characters, so that the are typed easily, usable as
  # variable names etc. This method thus removes punctuation, removes
  # superfluous spaces, and underscores the remaining ones, before returning
  # the string.
  # 
  def standardize
    ς = self.dup
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
