#encoding: utf-8

class String
  # Integer() style conversion, or false if conversion impossible.
  def can_be_integer?
    begin; int = Integer( self.stripn ); return int
    rescue AE; return false end
  end
  
  # Float() style conversion, or false if conversion impossible.
  def can_be_float?
    begin; fl = Float( self.stripn ); return fl
    rescue AE; return false end
  end
  
  # #stripn is like #strip, but also strips newlines
  def stripn; encode(universal_newline: true).gsub("\n", "").strip end
  
  # Joins a paragraph of possibly indented, newline separated lines into a
  # single contiguous string.
  def compact
    encode(universal_newline: true).split("\n"). # split into lines
      map( &:strip ).delete_if( &:blank? ).join " " # strip and join lines
  end
  
  # #default replaces an empty string (#empty?) with provided default
  # string.
  def default! default_string
    strip.empty? ? clear << default_string.to_s : self
  end
  
  # underscores spaces
  def underscore_spaces; gsub( ' ', '_' ) end
  
  # Strips a ς (#stripn), removes criminal chars & underscores spaces
  def symbolize
    x = self; ",.?!;".each_char{|c| x.gsub!(c, " ")}
    return x.stripn.squeeze(" ").underscore_spaces
  end
  alias :ßize :symbolize
  
  # chains #symbolize and #to_sym
  def to_normalized_sym; symbolize.to_sym end
  alias :ßß :to_normalized_sym
end
