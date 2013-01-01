# -*- coding: utf-8 -*-
class Symbol
  # This method applies String#default! method to the receiver converted to
  # a string. Of course, symbols are immutable, so in spite of the exclamation
  # mark in the method name, a new symbol (supplied as argument) is returned,
  # if the original one is considered "defaulted" (otherwise, original symbol
  # is returned unchanged).
  # 
  def default! default_symbol
    to_s.default!( default_symbol ).to_sym
  end
  
  # Applies String#to_standardized_sym method to the recevier converted to a
  # string.
  # 
  def to_standardized_sym
    to_s.to_standardized_sym
  end
  
  # Creates a RespondTo object from self. Intended use of RespondTo is in case
  # statements (RespondTo has customized #=== method testing #respond_to?).
  # So in a case statement, <tt>when ~:each</tt> activates when the tested
  # object responds to #each method.
  # 
  def ~@; RespondTo self end
end
