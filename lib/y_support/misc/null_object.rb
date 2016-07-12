# encoding: utf-8

require_relative '../../y_support'

# Null object pattern implementation in +YSupport+. apart from the expected null
# object behavior (such as returning self in response to almost all messages),
# this null object instances can carry a signature specified by the user upon
# creation, which can serve to hint the origin of the null object. (This
# signature is opional, default is <tt>nil</tt>.)
# 
class NullObject
  attr_reader :null_object_signature

  # Signature can be given as an optional argument upon initialization.
  # 
  def initialize null_object_signature=nil
    @null_object_signature = null_object_signature 
  end

  # Inquirer whether an object is a +NullObject+. Again, optional signature
  # argument can be given to distinguish between different null objects.
  # 
  def null_object? signature=nil
    null_object_signature == signature
  end
  alias null? null_object?

  # Empty array.
  # 
  def to_a; [] end

  # Description string.
  # 
  def to_s
    sgn = null_object_signature
    sgn.nil? ? "#<NullObject>" : "#<NullObject #{sgn}>"
  end

  # Inspection string.
  # 
  def inspect; to_s end

  # Float zero.
  # 
  def to_f; 0.0 end

  # Integer zero.
  # 
  def to_i; 0 end

  # Always false.
  # 
  def present?; false end

  # Always true.
  # 
  def empty?; true end

  # Always true.
  # 
  def blank?; true end

  # True if and only if the other object is a +NullObject+ with same signature.
  # 
  def == other
    other.is_a?( self.class ) &&
      other.null_object_signature == null_object_signature
  end

  def method_missing ß, *args, &block      # :nodoc:
    self
  end

  def respond_to? ß, *args, &block         # :nodoc:
    true
  end
end # class nullobject


class Object
  # Always false for ordinary objects, overriden in +NullObject+ instances.
  # 
  def null_object? signature=nil; false end
  alias :null? :null_object?

  # Converts +#nil?+-positive objects to a +NullObject+. Second optional
  # argument specifies the signature of the null object to be created.
  # 
  def Maybe object, null_object_signature=nil
    object.nil? ? NullObject.new( null_object_signature ) : object
  end

  # NullObject constructor.
  # 
  def Null( signature=nil ); NullObject.new signature end
end

