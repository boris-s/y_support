# -*- coding: utf-8 -*-

require 'y_support'
require_relative 'name_magic/array'
require_relative 'name_magic/class_methods'
require_relative 'name_magic/namespace_methods'

# This mixin imitates Ruby constant magic and automates the named argument
# :name (alias :ɴ). One thus can write:
#
# <tt>class Someclass; include NameMagic end</tt>
# <tt>SomeName = SomeClass.new</tt>
#
# and the resulting object will know its #name:
#
# <tt>SomeName.name = "SomeName"</tt>
#
# This is done by searching the whole Ruby namespace for constants, to which
# the object might have been assigned. The search is performed by the method
# #const_magic defined by this mixin. Once the object is found to be assigned
# to a constant, and named accordingly, its subsequent assignments to other
# constants have no additional effect.
#
# Alternative way to create a named object is by specifying :name (alias :ɴ)
# named argument:
#
# <tt>SomeClass.new a, b, ..., name: "SomeName", aa: v1, bb: v2 ...</tt>
#
# Lastly, a name can be assigned by #name= accssor, as in
#
# <tt>o = SomeClass.new</tt>
# <tt>o.name = "SomeName"</tt>
#
# Hook is provided for when the name magic is performed, as well as when the
# name is retrieved.
# 
module NameMagic
  DEBUG = false

  def self.included ɱ
    case ɱ
    when Class then # we will decorate its #new method
      class << ɱ
        alias :original_method_new :new # Make space to decorate #new
      end
      # Attach the decorators etc.
      ɱ.extend ::NameMagic::ClassMethods
      ɱ.extend ::NameMagic::NamespaceMethods
      # Attach namespace methods also to the namespace, if given.
      begin
        if ɱ.namespace == ɱ then
          ɱ.define_singleton_method :namespace do ɱ end
        else
          ɱ.namespace.extend ::NameMagic::NamespaceMethods
        end
      rescue NoMethodError
      end
    else # it is a Module; we'll infect it with our #included method
      ɱ_included, this_included = ɱ.method( :included ), method( :included )
      ɱ.define_singleton_method :included do |ç|
        this_included.( ç )
        ɱ_included.( ç )
      end
    end
  end # self.included

  # The namespace of the instance's class.
  # 
  def namespace
    self.class.namespace
  end

  # Retrieves an instance name (demodulized).
  # 
  def name
    self.class.const_magic
    __name__
  end

  # Retrieves an instance name. (Does not trigger #const_magic before doing so.)
  # 
  def __name__
    ɴ = self.class.__instances__[ self ]
    if ɴ then
      namespace.name_get_closure.( ɴ )
      name_get_closure ? name_get_closure.( ɴ ) : ɴ
    else nil end
  end
  alias ɴ name

  # Retrieves either an instance name (if present), or an object id.
  # 
  def name_or_object_id
    name || object_id
  end
  alias ɴ_ name_or_object_id

  # Names an instance, cautiously (ie. no overwriting of existing names).
  # 
  def name=( ɴ )
    puts "NameMagic: Naming with argument #{ɴ}." if DEBUG
    # get previous name of this instance, if any
    old_ɴ = self.class.__instances__[ self ]
    # honor the hook
    name_set_closure = self.class.instance_variable_get :@name_set_closure
    ɴ = name_set_closure.call( ɴ, self, old_ɴ ) if name_set_closure
    ɴ = self.class.send( :validate_capitalization, ɴ ).to_sym
    puts "NameMagic: Name adjusted to #{ɴ}." if DEBUG
    return if old_ɴ == ɴ # already named as required; nothing to do
    # otherwise, be cautious about name collision
    raise NameError, "Name '#{ɴ}' already exists in " +
      "#{self.class} namespace!" if self.class.__instances__.rassoc( ɴ )
    # since everything's ok...
    self.class.namespace.const_set ɴ, self # write a constant
    self.class.__instances__[ self ] = ɴ   # write __instances__
    self.class.__forget__ old_ɴ            # forget the old name of self
  end

  # Names an instance, aggresively (overwrites existing names).
  # 
  def name!( ɴ )
    puts "NameMagic: Rudely naming with argument #{ɴ}." if DEBUG
    old_ɴ = self.class.__instances__[ self ] # get instance's old name, if any
    # honor the hook
    name_set_closure = self.class.instance_variable_get :@name_set_closure
    ɴ = name_set_closure.( ɴ, self, old_ɴ ) if name_set_closure
    ɴ = self.class.send( :validate_capitalization, ɴ ).to_sym
    puts "NameMagic: Name adjusted to #{ɴ}." if DEBUG
    return false if old_ɴ == ɴ # already named as required; nothing to do
    # otherwise, rudely remove the collider, if any
    pair = self.class.__instances__.rassoc( ɴ )
    self.class.__forget__( pair[0] ) if pair
    # and add self to the namespace instead
    self.class.namespace.const_set ɴ, self # write a constant
    self.class.__instances__[ self ] = ɴ   # write to __instances__
    self.class.__forget__ old_ɴ            # forget the old name of self
    return true
  end
end # module NameMagic
