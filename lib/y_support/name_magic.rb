# encoding: utf-8

require_relative '../y_support'
require_relative 'core_ext/hash/misc'
require_relative 'literate'

# Module NameMagic imitates Ruby constant magic and automates the
# named argument :name, alias :ɴ (Character "ɴ", Unicode small
# capital N). At the same time, NameMagic provides the registry of
# instances of the user class. In Ruby, we frequently want to keep
# a list of instances of some classes, and NameMagic also helps
# with this task. Simple example:
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
# Additionally, NameMagic provides two hooks: Instantiation hook
# activates when a new instance is created, and naming hook
# activates when the created instance is baptized. Let us set the
# first hook, for example, as follows:
#
#   Foo.instantiation_hook do |instance|
#     puts "New instance of Foo with object id " +
#           "#{instance.object_id} created!"
#   end
#
# Now let us set the second hook as follows:
#
#   Foo.naming_hook do |name, instance|
#     puts "Instance with object id #{instance.object_id} " +
#          "is baptized #{name}!"
#     name
#   end
#
# Note that the naming hook must always return name. (This can be
# used to censor the name on the fly, but that's beyond this basic
# intro.) Now that we set the hooks, let us observe when do they
# activate:
#
#   i = Foo.new
#   New instance of Foo with object id 73054440 created!
#
#   Baz = i
#   Instance with object id 73054440 is baptized Baz!
#  
# We can see that the registry of instances now registers two
# instances:
#
#   Foo.instances #=> [Bar, Baz]
#
# NameMagic has been programmed to be simple and intuitive to use,
# so with this little demonstration, you can start using it without
# fear. You can find the rest of the methods provided by NameMagic
# in the documentation.
# 
# However, behind the scenes, inner workings of NameMagic require
# understanding.  The key part of NameMagic is the code that
# searches Ruby namespace for constants. This search is done
# automatically when necessary. It can be also explicitly initiated
# by calling .const_magic class method, but this is rarely
# needed. When you write "include NameMagic" in some class, three
# things happen:
#
# 1. Module NameMagic is included in that class, as expected.
# 2. Class is extended with NameMagic::ClassMethods.
# 3. Namespace is extended with NameMagic::NamespaceMethods.
#
# Namespace (in the NameMagic sense) is a module that holds the
# list of instances and their names. Typically, the user class acts
# as its own namespace. Note that the meaning of the word
# 'namespace' is somewhat different from its meaning in general
# Ruby. NameMagic actually provides class method .namespace that
# returns the namespace of the class. Consider this example:
#
#   require 'y_support/name_magic'
#   class Animal
#     include NameMagic
#   end
#   Animal.namespace #=> Animal
# 
# We can see that the namespace of Animal class is again Animal
# class. But when we subclass it:
#
#   class Dog < Animal; end
#   class Cat < Animal; end
#   Dog.namespace #=> Animal
#   Cat.namespace #=> Animal
#
# The subclasses retain Animal as their namespace. Let us continue
# with the example:
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
# Make the subclasses be their own namespaces with +#namespace!:
#
#   Dog.namespace!
#   
# NameMagic also provides another way of naming objects by taking
# care of :name (alias :ɴ) parameter of #new constructor:
#
#   Dog.new name: "Spot"
#   Dog.new.name = :Rover
#   Dog.instances._names_ #=> [:Spot, :Rover]
#   Animal.instances._names_ #=> []
#
# Note that the Dog instances above did not disappear even though
# we did not assign them to any variables or constants. This is
# because the instances of the classes using NameMagic, whether
# named or not, are since their creation referred to from the
# instance registry, which prevents them from being garbage
# collected. To get rid of Spot and Rover, we would have to delete
# them from the instance registry:
#
#   Dog.forget "Spot"
#   Dog.forget "Rover"
#
# Spot and Rover show their inspect string for the last time and
# are garbage collected.
# 
module NameMagic
  require_relative 'name_magic/array_methods'
  require_relative 'name_magic/hash_methods'

  Array.class_exec { include ArrayMethods }
  Hash.class_exec { include HashMethods }

  require_relative 'name_magic/namespace'
  require_relative 'name_magic/class_methods'

  def self.included target
    if target.is_a? Class then
      # Define target.namespace method.
      target.singleton_class.class_exec do
        # Primer that sets the namespace of the class to self if
        # the user has not defined otherwise when this method is
        # first called.
        # 
        define_method :namespace do
          # The method first extends target with Namespace methods.
          target.extend NameMagic::Namespace
          # The method then redefines itself.
          define_singleton_method :namespace do target end
          # And finally calls the redefined version of itself.
          namespace
        end
      end
      # Prepend NameMagic::ClassMethod to class << target.
      target.singleton_class.class_exec do
        prepend NameMagic::ClassMethods
      end
    else # Target is a Module, infect it with this #include
      original_included_method = target.method :included
      this_method = method :included
      target.define_singleton_method :included do |target|
        this_method.( target )
        original_included_method.( target )
      end
    end
  end # self.included

  # The namespace of the instance's class.
  # 
  def namespace
    self.class.namespace
  end

  # Retrieves the demodulized instance's name as a symbol.
  # "Demodulized" means that if the full name is "Foo::Bar", only
  # :Bar is returned. Underlines (+#_name_+) distinguish this
  # method from +#name+ method, which returns full name string for
  # compatibility with vanilla Ruby +Module#name+.
  # 
  def _name_
    self.class.const_magic
    __name__ or ( yield self if block_given? )
  end
  alias ɴ _name_
  # FIXME: Delete the line below! Do it!  Make #name return
  # #full_name, as compatible with Class#name behavior!!!
  alias name _name_

  # Returns the instance's full name, a string in the style of
  # those returned by +Module#name+ method, eg. "Namespace::Name".
  # 
  def full_name
    # FIXME: This method cannot work until Namespace#const_magic
    # starts noticing not just constant names, as it does now,
    # but also names of the modules those constants are in. This
    # is no simple task.
    #
    # The code below is the closest approximation, yet still
    # patently wrong.
    [ namespace.name || namespace.inspect,
      namespace.instances[ self ]
    ].join "::"
  end
  # FIXME: Uncomment the line below! Do it! Make #name return
  # #full_name, as compatible with Class#name behavior!!!  alias
  # name full_name
  
  # Retrieves the instance name. Does not trigger #const_magic
  # before doing so.
  # 
  def __name__
    self.class.__instances__[ self ]
  end

  # Names the receiver, while rejecting names already in use by
  # another instance. If nil is supplied as an argument, unnames
  # the instance. (This method does not trigger const_magic.)
  # 
  def name=( name )
    # If the argument is nil, the method performs unnaming.
    return unname! if name.nil?
    # Otherwise, the method performs naming the instance, while
    # avoiding stealing names already in use by another instance.
    # Let us look at the current name of the instance first.
    previous_name = namespace.__instances__[ self ]
    # Honor class'es #exec_when_naming hook.
    requested_new_name = honor_exec_when_naming( name )
    # Return if the instance is already named as requested.
    return if previous_name == requested_new_name
    # Raise error if the requested name is already taken.
    self.class.__instances__.rassoc( requested_new_name ) and
      fail NameError, "Name '#{requested_new_name}' already " +
                      "exists in #{namespace} namespace!"
    # Now it is sure that the instance will be named, so it does
    # not need to be avid.
    make_not_avid!
    # Rename self by modifying the registry.
    namespace.__instances__.update self => requested_new_name
    # Honor instance's #exec_when_named hook.
    honor_exec_when_named
  end

  # Names the receiver aggresively. "Aggresively" means that in
  # case the requested new name of the instance is already in use
  # by another instance, the other instance is unnamed. In other
  # words, in case of conflict of a name, the name is stolen from
  # the conflicting instance, which becomes unnamed as a result.
  # (The method does not trigger const_magic.)
  # 
  def name!( name )
    # If the argument is nil, the method performs unnaming.
    return unname! if name.nil?
    # Otherwise, the method performs aggresive naming the instance,
    # where "aggresive" means that in case of conflict over a name,
    # the name is stolen from the conflicting instance.
    # Let us look at the current name of the instance first.
    previous_name = namespace.__instances__[ self ]
    # Honor class'es #exec_when_naming hook.
    requested_new_name = honor_exec_when_naming( name )
    # Return if the instance is already named as requested.
    return if previous_name == requested_new_name
    # See if the requested name is already taken.
    colliding_entry =
      namespace.__instances__.rassoc( requested_new_name )
    # Unname the colliding instance, if any.
    begin
      colliding_entry.first.unname! if colliding_entry
    ensure
      # Unnaming the colliding instance may fail. But whether it
      # fails or succeeds, self must quit being avid. If the
      # unnaming succeeded, self is getting a new name and thus
      # no longer needs to be avid. However, if the unnaming
      # raises an error, we want to avoid seeing the same error
      # over and over again just because avid self assigned to
      # a constant with conflicting name tries over and over again
      # to perform the impossible feat of stealing that name.
      make_not_avid!
    end
    # Rename self by modifying the registry.
    namespace.__instances__.update self => requested_new_name
    # Honor instance's #exec_when_named hook.
    honor_exec_when_named
    # Return the receiver.
    return self
  end

  # Unnames the instance. Does not trigger #const_magic.
  # 
  def unname!
    # Get the current name of the instance.
    name = namespace.__instances__[ self ]
    # If the instance is anonymous, we are done.
    return if name.nil?
    # Check whether unnaming instances is allowed at all.
    fail NameError, "Unnaming and naming by a name already in " +
      "use by another instance has been disallowed!" unless
      unnaming_allowed?
    # Honor class'es #exec_when_unnaming hook.
    honor_exec_when_unnaming
    # Unname the instance by deleting the name from the registry.
    namespace.__instances__.update( self => nil )
    # Honor instance's #exec_when_unnamed hook.
    honor_exec_when_unnamed
    # Return value is the previous name.
    return name
  end

  # Is the instance avid? ("Avid" means that the instance is so
  # eager to get a name that it will use name even if this is
  # already in use by another instance.)
  # 
  def avid?
    namespace.__avid_instances__.any? &method( :equal? )
  end

  # Make the instance not avid.
  # 
  def make_not_avid!
    namespace.__avid_instances__.delete_if { |i| equal? i }
    return nil
  end

  # Is unnaming of the instance allowed? Note: This method just
  # relies on class'es .permanent_names? method. Unnaming is not
  # allowed when .permanent_names? is true.
  # 
  def unnaming_allowed?
    ! self.class.permanent_names?
  end

  # Registers a block to execute as soon as the instance is named.
  # (In other words, this method provides instance's naming hook.)
  # The block is executed in the context of the instance. Return
  # value of the block is unimportant. If no block is given, the
  # method returns the previously defined block, if any, or a
  # default block that does nothing.
  # 
  def exec_when_named &block
    @exec_when_named = block if block
    @exec_when_named ||= -> { }
  end
  # Note: This alias must stay while the dependencies need it.
  alias name_set_hook exec_when_named

  # Registers a block to execute right after the instance is
  # unnamed. (In other words, this method provides instance's
  # unnaming hook.) The block is executed in the context of the
  # instance. Return value of the block is unimportant. If no block
  # is given, the method returns the previously defined block, if
  # any, or a default block that does nothing.
  # 
  def exec_when_unnamed &block
    @exec_when_unnamed = block if block
    @exec_when_unnamed ||= -> { }
  end
  # Note: This alias must stay while the dependencies need it.
  alias name_set_hook exec_when_named

  # +NameMagic+ redefines #to_s method to show names.
  # name.
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

  # Make the instance avid. Does not trigger const_magic. (Remark:
  # Invoking this method on named instances is considered gross
  # indecency.)
  # 
  def make_avid!
    namespace.__avid_instances__ << self unless
      namespace.__avid_instances__.any? { |i| i.equal? self }
    return nil
  end

  # Honors the class'es hook #exec_when_naming. Takes 2
  # arguments, name and old name of this instance. Also calls
  # Namespace#validate_name method. Returns the final name to be
  # used.
  # 
  def honor_exec_when_naming( suggested_name )
    instance = self
    previous_name = namespace.__instances__[ instance ]
    suggested_name = suggested_name.to_s
    # Calling exec_when_naming without a block makes the method
    # return the block defined earlier.
    block = self.class.exec_when_naming
    # Execute the namespace hook in the context of the user class.
    name = self.class.instance_exec( suggested_name,
                                     instance,
                                     previous_name,
                                     &block )
    # The hook is supposed to return the name to be actually used.
    # But if the user used the block for other purposes and did
    # not bother to return a string or symbol (or anything that
    # can be converted to a symbol), we will assume that the user
    # meant to leave the suggested name without intervention.
    # I wonder whether this behavior is too smart.
    name = begin; name.to_sym; rescue NoMethodError
             suggested_name
           end
    # Finally, apply validate_name method and return the result.
    return self.class.validate_name( name ).to_sym
  end

  # Honors instance's hook #exec_when_named.
  # 
  def honor_exec_when_named
    # Method #exec_when_named, when called without a block, returns
    # the block defined earlier.
    block = exec_when_named
    # Block is executed within the context of this instance.
    instance_exec &block
    # The method returns nil.
    return nil
  end

  # Honors the class'es hook #exec_when_unnaming.
  # 
  def honor_exec_when_unnaming
    instance = self
    previous_name = namespace.__instances__[ instance ]
    # Calling exec_when_unnaming without a block makes the method
    # return the block defined earlier.
    block = self.class.exec_when_unnaming
    # Execute the namespace hook in the context of the user class.
    name = self.class.instance_exec( instance,
                                     previous_name,
                                     &block )
    # The method returns nil.
    return nil
  end

  # Honors instance's hook #exec_when_unnamed.
  # 
  def honor_exec_when_unnamed
    # Method #exec_when_unnamed, when called without a block,
    # returns the block defined earlier.
    block = exec_when_unnamed
    # Block is executed within the context of this instance.
    instance_exec &block
    # The method returns nil.
    return nil
  end
end # module NameMagic
