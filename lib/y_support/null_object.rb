#encoding: utf-8
require 'y_support'

# InertRecorder class
class InertRecorder
  attr_reader :init_args, :init_block, :recorded_messages
  alias ρ recorded_messages
  
  def initialize *args, &block
    @init_args = args
    @init_block = block
    @recorded_messages = []
  end
  
  def method_missing ß, *aj, &b
    @recorded_messages << [ ß, aj, b ]
    return self
  end

  def respond_to? ß, *aj, &b
    true
  end

  def present?
    true
  end

  def blank?
    false
  end
end # class InertRecorder


# YSupport implementation of null object pattern. Apart from being useful
# as a null object, it also can have "null object type" specified, if the
# user desires so (default is <tt>nil</tt>). Furthermore, this object acts
# also as inert recorder – it records messages sent to it, which are then
# available as #recorded_messages, alias #ρ.
# 
class NullObject
  attr_reader :null_object_type, :recorded_messages
  alias ρ recorded_messages

  # The only possible (optional) argument upon initialization of a null
  # object is its "type" (which can be anything).
  # 
  def initialize( type_of_null_object = nil )
    @null_object_type = type_of_null_object
    @recorded_messages = []
  end

  # Always an empty array.
  # 
  def to_a; [] end

  # Description string ('null something', or simply 'null').
  # 
  def to_s; "null #{null_object_type}".strip end

  # Always Float zero.
  # 
  def to_f; 0.0 end

  # Always Integer zero.
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

  def inspect                        # :nodoc:
    "NullObject #{null_object_type}".strip
  end

  def method_missing ß, *aj, &b      # :nodoc:
    @recorded_messages << [ ß, aj, b ]; self
  end

  def respond_to? ß, *aj, &b         # :nodoc:
    true
  end

  protected

  def == other                       # :nodoc:
    null_object_type == other.null_object_type
  end
end # class NullObject
