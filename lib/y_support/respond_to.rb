require 'y_support'

# RespondTo class for easy use of respond_to? in case statements.
# 
class RespondTo
  Matchers = {}
  attr_reader :method
  def self.create method; Matchers[ method ] ||= new method end
  def initialize method; @method = method end
  def === obj; obj.respond_to? method end
end


class Object
  # RespondTo constructor.
  # 
  def RespondTo method; RespondTo.create method end
end


class Symbol
  # Creates a RespondTo object from the receiver symbol. Intended use for this
  # is nin case statements: RespondTo has customized #=== method, that calls
  # #respond_to? to determine the return value.
  # 
  # For example, <tt>when ~:each</tt> in a case statement is valid only if the
  # tested object respond_to?( :each ) returns true.
  # 
  def ~@; RespondTo self end
end

