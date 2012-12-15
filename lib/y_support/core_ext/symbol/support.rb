# -*- coding: utf-8 -*-
class Symbol
  # Symbol's method #default! just applies String's #dℲ! to a Symbol. Of
  # course, a symbol cannot change, so despite the exclamation mark, new
  # symbol is returned whenever the original is considered "defaulted".
  # Ordinary #default does not work with symbols, as symbols are never
  # considered blank.
  # 
  def default!( default_value )
    to_s.default!( default_value ).to_sym
  end
  
  # Chains #symbolize and #to_sym.
  # 
  def to_normalized_sym; to_s.to_normalized_sym end
  alias :ßß :to_normalized_sym
  
  # Creates a RespondTo object from self. (Usef for ~:symbol style matching
  # in case statements).
  # 
  def ~@; RespondTo self end
end
