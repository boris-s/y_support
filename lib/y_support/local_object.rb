#encoding: utf-8

require 'y_support'

# Object, whose business is to stay local to methods. Optional signature
# provides additional level of safety in ensuring object locality. (Signature
# accessor is :signature, aliased as :σ (small Greek sigma).)
# 
class LocalObject
  attr_reader :signature
  alias σ signature

  # Optional argument signature provides additional level of safety in
  # ascertaining that the object indeed is of local origin.
  # 
  def initialize signature=__callee__
    @signature=signature
  end

  # True if the (optional) signature matches.
  # 
  def local_object? signature=__callee__
    signature == self.signature
  end
  alias ℓ? local_object?
end


class Object
  # LocalObject constructor.
  # 
  def LocalObject signature=nil; LocalObject.new signature end
  alias L! LocalObject

  # False for normal objects, overriden in the LocalObject class.
  # 
  def local_object? signature=nil; false end
  alias ℓ? local_object?
end
