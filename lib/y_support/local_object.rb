#encoding: utf-8
require 'y_support'

# Object that should stay local to methods.
# 
class LocalObject
  attr_reader :signature
  alias :σ :signature
  def initialize sgn = nil; @signature = sgn end
end

