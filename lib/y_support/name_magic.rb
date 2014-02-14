# encoding: utf-8

require 'y_support'
require 'y_support/core_ext/hash/misc'

require_relative 'name_magic/array'
require_relative 'name_magic/hash'

# This mixin imitates Ruby constant magic and automates the named argument
# :name, alias :ɴ (Character "ɴ", Unicode small capital N, generally stands
# for "name" ins YSupport). One can write:
#
#   require 'y_support/name_magic'
#   class Foo; include NameMagic end
#   Bar = Foo.new
#
# and the resulting object will know its #name:
#
#   Bar._name_ #=> :Bar
#   Bar.full_name #=> "Foo::Bar"
#   Foo::Bar #=> <Foo:0x.....>
#
# This is done by searching whole Ruby namespace for constants, triggered by the
# method #const_magic defined in the namespace mixin. (Once the object is named,
# subsequent constant assignments have no effects.) By default, the namespace
# is the class, in which NameMagic is included, but it is possible to prescribe
# another module as a namespace:
#
#   Quux = Module.new
#   class FooBar
#     include NameMagic
#     self.namespace = Quux
#   end
#   FooBar.new name: "Baz"
#   FooBar::Baz #=> NameError
#   Quux::Baz #=> <FooBar:0x.....>
#
# When subclassing the classes with NameMagic included, namespace setting does
# not change:
#
#   class Animal; include NameMagic end
#   class Dog < Animal; end
#   class Cat < Animal; end
#   Dog.namespace #=> Animal
#   Cat.namespace #=> Animal
#   Livia = Cat.new
#   Cat.instances._names_ #=> []
#   Animal.instances._names_ #=> [:Livia]
#
# To make the subclasses use each their own namespace, use +#namespace!+ method:
#
#   Dog.namespace!
#   
# NameMagic also provides an alternative way to create named objects by taking
# care of :name (alias :ɴ) named argument of the constructor:
#
#   Dog.new name: "Spot"
#   Dog.new ɴ: :Rover
#   Dog.instances._names_ #=> [:Spot, :Rover]
#   Animal.instances._names_ #=> []
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

  require_relative 'name_magic/namespace_methods'
  require_relative 'name_magic/class_methods'

  def self.included target
    if target.is_a? Class then # decorate #new
      target.singleton_class.class_exec do
        # Primer that sets the namespace of the class to self if the user has
        # not defined otherwise when this method is first called.
        # 
        define_method :namespace do
          target.extend ::NameMagic::NamespaceMethods
          define_singleton_method :namespace do target end # redefines itself
          namespace
        end
      end
      target.singleton_class.class_exec { prepend ::NameMagic::ClassMethods }
    else # it is a Module -- infect it with this #include
      orig, this = target.method( :included ), method( :included )
      target.define_singleton_method :included do |m| this.( m ); orig.( m ) end
    end
  end # self.included

  # The namespace of the instance's class.
  # 
  def namespace
    self.class.namespace
  end

  # Retrieves the instance's name not prefixed by the namespace as a symbol.
  # Underlines (+#_name_+) distinguish this method from +#name+ method, which
  # returns full name string for compatibility with vanilla Ruby +Module#name+.
  # 
  def _name_
    self.class.const_magic
    __name__ or ( yield self if block_given? )
  end
  alias ɴ _name_
  # FIXME: Delete the line below! Do it!  Make #name return #full_name, as compatible with Class#name behavior!!!
  alias name _name_

  # Returns the instance's full name, a string in the style of those returned
  # by +Module#name+ method, eg. "Namespace::Name".
  # 
  def full_name
    "#{namespace.name || namespace.inspect}::#{namespace.instances[ self ]}"
  end
  # FIXME: Uncomment the line below! Do it! Make #name return #full_name, as compatible with Class#name behavior!!!
  # alias name full_name
  
  # Retrieves the instance name. Does not trigger #const_magic before doing so.
  # 
  def __name__
    ɴ = self.class.__instances__[ self ]
    namespace.name_get_hook.( ɴ ) if ɴ
  end

  # Names an instance, cautiously (ie. no overwriting of existing names).
  # 
  def name=( name )
    old_ɴ = namespace.__instances__[ self ]         # previous name
    if name.nil? then
      namespace.__instances__.update( self => nil ) # unname in @instances
      namespace.send :remove_const, old_ɴ if old_ɴ  # remove namespace const.
    else
      ɴ = honor_name_set_hooks( name, old_ɴ )
      return if old_ɴ == ɴ                  # already named as required
      fail NameError, "Name '#{ɴ}' already exists in #{namespace} namespace!" if
        self.class.__instances__.rassoc( ɴ )
      namespace.__forget__ old_ɴ            # forget the old name of self
      namespace.const_set ɴ, self           # write a constant
      namespace.__instances__[ self ] = ɴ   # write to @instances
    end
  end

  # Names an instance, aggresively (overwrites existing names).
  # 
  def name!( name )
    old_ɴ = namespace.__instances__[ self ]   # previous name
    return self.name = nil if name.nil?       # no collider concerns
    ɴ = honor_name_set_hooks( name, old_ɴ )
    return false if old_ɴ == ɴ                # already named as required
    pair = namespace.__instances__.rassoc( ɴ )
    namespace.__forget__( pair[0] ) if pair   # rudely forget the collider
    namespace.__forget__ old_ɴ                # forget the old name of self
    namespace.const_set ɴ, self               # write a constant
    namespace.__instances__[ self ] = ɴ       # write to @instances
  end

  # Is the instance avid for a name? (Will it overwrite other instance names?)
  # 
  def avid?
    namespace.__avid_instances__.any? &method( :equal? )
  end

  # Make the instance not avid.
  # 
  def make_not_avid!
    namespace.__avid_instances__.delete_if { |i| i.object_id == object_id }
  end

  # Registers a hook to execute upon instance naming. Instance's `#name_set_hook`
  # Behaves analogically as namespace's `#name_set_hook`, and is executed right
  # after the namespace's hook. Expects a block with a single argument, name of
  # the instance. The return value of the block is not used and should be _nil_.
  # Without a block, this method acts as a getter.
  # 
  def name_set_hook &block
    @name_set_hook = block if block
    @name_set_hook ||= -> name { nil }
  end

  private

  # Honors name set hooks, first for the namespace, then for the instance.
  # Takes 2 arguments, name and old name of this instance. Returns the final
  # name to be used
  # 
  def honor_name_set_hooks suggested_name, old_name
    ɴ = namespace.name_set_hook.( suggested_name, self, old_name ).to_sym
    # puts "NameMagic: Name adjusted to #{name}." if DEBUG
    namespace.validate_name( ɴ ).tap { |ɴ| name_set_hook.( ɴ ) }
  end
end # module NameMagic
