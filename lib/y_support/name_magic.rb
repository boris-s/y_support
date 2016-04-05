# encoding: utf-8

require_relative '../y_support'
require_relative '../y_support/core_ext/hash/misc'
require_relative 'name_magic/array'
require_relative 'name_magic/hash'

# Module NameMagic imitates Ruby constant magic and automates the named argument
# :name, alias :ɴ (Character "ɴ", Unicode small capital N). At the same time,
# NameMagic provides the registry of instances of the user class. In Ruby, we
# frequently want to keep a list of instances of some classes, and NameMagic
# also helps with this task. Simple example:
#
#   require 'y_support/name_magic'
#   class Foo
#     include NameMagic
#   end
#   Bar = Foo.new
#
# The resulting object will know its +#name+:
#
#   Bar.name #=> "Bar"
#
# We can get the list of instances by:
#
#   Foo.instances #=> [Bar]
#
# Additionally, NameMagic provides two hooks: Instantiation hook activates
# when a new instance is created, and naming hook activates when the created
# instance is baptized. Let us set the first hook, for example, as follows:
#
#   Foo.instantiation_hook do |instance|
#     puts "New instance of Foo with object id #{instance.object_id} created!"
#   end
#
# Now let us set the second hook as follows:
#
#   Foo.naming_hook do |name, instance|
#     puts "Instance with object id #{instance.object_id} is baptized #{name}!"
#     name
#   end
#
# Note that the naming hook must always return name. (This can be used to
# censor the name on the fly, but that's beyond this basic intro.) Now that
# we set the hooks, let us observe when do they activate:
#
#   i = Foo.new
#   New instance of Foo with object id 73054440 created!
#
#   Baz = i
#   Instance with object id 73054440 is baptized Baz!
#  
# We can see that the registry of instances now registers two instances:
#
#   Foo.instances #=> [Bar, Baz]
#
# NameMagic has been programmed to be simple and intuitive to use, so with this
# little demonstration, you can start using it without fear. You can find the
# rest of the methods provided by NameMagic in the documentation.
# 
# However, behind the scenes, inner workings of NameMagic require understanding.
# The key part of NameMagic is the code that searches Ruby namespace for
# constants. This search is done automatically when necessary. It can be also
# explicitly initiated by calling .const_magic class method, but this is
# rarely needed. When you write "include NameMagic" in some class, three
# things happen:
#
# 1. module NameMagic is included in that class, as expected.
# 2. The user class is extended with module NameMagic::ClassMethods.
# 3. The namespace is extended with module NameMagic::NamespaceMethods.
#
# Namespace (in the NameMagic sense) is a module that holds the list of
# instances and their names. Typically, the user class acts as its own
# namespace. Note that the meaning of the word 'namespace' is somewhat
# different from its meaning in general Ruby. NameMagic actually provides
# class method .namespace that returns the namespace of the class. Consider
# this example:
#
#   require 'y_support/name_magic'
#   class Animal; include NameMagic end
#   Animal.namespace #=> Animal
# 
# We can see that the namespace of Animal class is again Animal class. But
# when we subclass it:
#
#   class Dog < Animal; end
#   class Cat < Animal; end
#   Dog.namespace #=> Animal
#   Cat.namespace #=> Animal
#
# The subclasses retain Animal as their namespace. Let us continue with the
# example:
#
#   Livia = Cat.new
#   Cat.instances #=> [Livia]
#   Dog.instances #=> []
#   Animal.instances #=> [Livia]
#
# Let us demonstrate alternative ways of creating named objects:
#
#   Dog.new name: :Spot
#   Dog.new ɴ: "Rover"
#   Cat.instances #=> [Livia]
#   Dog.instances #=> [Spot, Rover]
#   Animal.instances #=> [Livia, Spot, Rover]
#
# To make the subclasses use each their own namespace, use +#namespace!+ method:
#
#   Dog.namespace!
#   
# NameMagic also provides an alternative way to create named objects by taking
# care of :name (alias :ɴ) named argument of the constructor:
#
#   Dog.new name: "Spot"
#   Dog.new.name = :Rover
#   Dog.instances._names_ #=> [:Spot, :Rover]
#   Animal.instances._names_ #=> []
#
# Note that the Dog instances above did not disappear even though we did not
# assign them to any variables or constants. This is because the instances of
# the classes using NameMagic, whether named or not, are since their creation
# referred to from the instance registry, which prevents them from being
# garbage collected. To get rid of Spot and Rover, we would have to delete
# them from the instance registry:
#
#   Dog.forget "Spot"
#   Dog.forget "Rover"
#
# Spot and Rover show their inspect string for the last time and are garbage
# collected. 
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
    tap { @name_set_hook = block } if block
    @name_set_hook ||= -> name { nil }
  end

  # Default +#to_s+ method for +NameMagic+ includers, returning the name.
  # 
  def to_s
    name ? name.to_s : super
  end

  # Default +#inspect+ method for +NameMagic+ includers.
  # 
  def inspect
    to_s
  end

  private

  # Honors name set hooks, first for the namespace, then for the instance.
  # Takes 2 arguments, name and old name of this instance. Returns the final
  # name to be used
  # 
  def honor_name_set_hooks suggested_name, old_name
    ɴ = namespace.name_set_hook.( suggested_name, self, old_name ).to_sym
    # puts "NameMagic: Name adjusted to #{name}." if DEBUG
    namespace.validate_name( ɴ ).to_sym.tap { |ɴ| name_set_hook.( ɴ ) }
  end
end # module NameMagic
