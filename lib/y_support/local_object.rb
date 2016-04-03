# encoding: utf-8

require_relative '../y_support'

# Object, whose business is to stay local to methods. Optional signature
# provides additional level of safety in ensuring object locality. (Signature
# accessor is :signature, aliased as :σ, small Greek sigma.)
# 
class LocalObject
  attr_reader :signature
  alias σ signature

  # Optional argument signature provides additional level of safety in
  # ascertaining that the object indeed is of local origin.
  # 
  def initialize signature=caller_locations( 1, 1 )[0].label
    @signature = signature
  end

  # True if the (optional) signature matches.
  # 
  def local_object? signature=caller_locations( 1, 1 )[0].label
    signature == self.signature
  end
  alias ℓ? local_object?
end

# Object class is patched with #LocalObject (alias L!) constructor, and
# #local_object?, alias #ℓ? inquirer.
# 
class Object
  # LocalObject constructor.
  # 
  def LocalObject signature=caller_locations( 1, 1 )[0].label
    LocalObject.new signature
  end
  alias L! LocalObject

  # False for normal objects, overriden in the LocalObject class.
  # 
  def local_object? signature=nil; false end
  alias ℓ? local_object?
end
