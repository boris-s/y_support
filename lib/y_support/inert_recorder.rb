#encoding: utf-8

require 'y_support'

# Inert recorder is similar to a null object in the sense, that in response to
# almost all messages it returns self. But in addition, it records received
# messages along with their arguments and blocks (if given). Recoded messages
# are available via #recorded_messages reader, aliased #ρ (small Greek rho).
# Inert recorder does not require any arguments for initalization, but if they
# are supplied, they are silently recoded into @init_args (for arguments) and
# @init_block (for block, if given) instance variables, exposed via standard
# readers.
# 
class InertRecorder
  attr_reader :init_args, :init_block, :recorded_messages
  alias ρ recorded_messages

  # No arguments are required for initialization, but if they are supplied, they
  # are silently recorded into @init_args (for argument array) and @init_block
  # (for block, if given) instance variables, exposed via standard readers.
  # 
  def initialize *args, &block
    @init_args = args
    @init_block = block
    @recorded_messages = []
  end

  # Always true.
  # 
  def present?; true end

  # Always false.
  # 
  def blank?; false end

  # Always true.
  # 
  def respond_to? ß, *args, &block; true end

  def method_missing ß, *args, &block      # :nodoc:
    @recorded_messages << [ ß, args, block ]
    return self
  end
end # class InertRecorder


class Object
  # InertRecorder constructor.
  # 
  def InertRecorder *args, &block; InertRecorder.new *args, &block end
end
