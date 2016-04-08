# encoding: utf-8

# Class methods for the classes that include NameMagic.
# 
module NameMagic::ClassMethods
  # Delegates methods to the namespace used by the class. Since the
  # class frequently acts as its own namespace, this delegation
  # requires special handling.
  # 
  def self.delegate_to_namespace *symbols
    symbols.each { |ß|
      module_eval "def #{ß} *args\n" +
                  "  return super if namespace == self\n" +
                  "  namespace.#{ß}( *args )\n" +
                  "end"
    }
  end

  delegate_to_namespace :permanent_names!
  delegate_to_namespace :permanent_names?
  delegate_to_namespace :__instances__
  delegate_to_namespace :__avid_instances__
  delegate_to_namespace :const_magic
  delegate_to_namespace :validate_name
  delegate_to_namespace :forget_nameless_instances
  delegate_to_namespace :instantiation_exec
  delegate_to_namespace :exec_when_naming
  delegate_to_namespace :exec_when_unnaming

  # Note: These aliases must stay while the dependencies need them.
  alias new_instance_hook instantiation_exec
  alias name_set_hook exec_when_naming

  # Sets the namespace for the class.
  # 
  def namespace= modul
    fail "Namespace cannot be redefined when instance registry " +
         "is not empty!" unless instances.empty?
    modul.extend ::NameMagic::Namespace
    define_singleton_method :namespace do modul end
  end

  # Sets the namespace for the class to self.
  # 
  def namespace!
    nil.tap { self.namespace = self }
  end

  # Returns the registered instances. Example:
  # 
  # <code>
  # class Animal; include NameMagic end
  # Cat, Dog = Class.new( Animal ), Class.new( Animal )
  # Spot, Livia = Dog.new, Cat.new
  # Animal.instances #=> [Spot, Livia]
  # Dog.instances #=> [Spot]
  # Cat.instances #=> [Livia]
  # </code>
  #
  def instances
    return super if namespace == self
    namespace.instances.select { |i| i.kind_of? self }
  end

  # Returns the instance identified by the first argument.
  # 
  def instance instance
    return super if namespace == self
    namespace.instance( instance ).tap do |i|
      fail NameError, "No #{self} instance #{instance} " +
        "registered in #{namespace}!" unless i.kind_of? self
    end
  end

  # Returns those of the registered instances, which are nameless.
  # 
  def nameless_instances
    return super if namespace == self
    __instances__
      .select { |key, val| val.nil? and key.is_a? self }
      .keys
  end

  # Clears namespace-owned references to the specified
  # instance. (This is different from de-naming an instance by
  # setting <code>inst.name = nil</code>, which makes the instance
  # anonymous, but still registered.)
  # 
  def forget instance
    return super if namespace == self
    namespace.forget( instance instance )
  end

  # De-registers an instance without performing #const_magic
  # first. The argument must be a registered instance, or TypeError
  # ensues. Returns instance name for forgotten named instances,
  # _nil_ for forgotten nameless instances.
  # 
  def __forget__ instance
    fail TypeError, "Supplied argument is not an instance " +
                    "of #{self}!" unless instance.is_a? self
    return super if namespace == self
    namespace.__forget__ instance
  end

  # Clears references to all the instances.
  # 
  def forget_all_instances
    return super if namespace == self
    instances.map { |instance| __forget__ instance }
  end

  # In addition to the ability to name objects by constant
  # assignment it provides, +NameMagic+ modifies #new method so
  # that it will swallow certain parameters, namely +:name+ (alias
  # +:ɴ+), +:name!+ and +:avid+. These can be used to name
  # instances right off the bat with #new constructor:
  #
  # Human = Class.new do include NameMagic end
  # Human.new name: "Fred"
  # Human.instances #=> [Fred]
  # 
  # Option +:avid+ (_true_ or _false_), when set to _true_, makes
  # the instance so eager to be named that it will overwrite
  # (steal) names already given to other instances. This allows us
  # to redefine names to which we have already assigned something
  # else.
  #
  # Finally, parameter +:name!+ acts as +:name+ with +:avid+ set to
  # _true_:
  # 
  # instance_1 = Human.new name: "Joe"
  # instance_1.name #=> :Joe
  # Human.instance( :Joe ) == instance_1 #=> true
  # instance_2 = Human.new name!: "Joe"
  # instance_2.name #=> :Joe
  # instance_1.name #=> nil
  # Human.instance( :Joe ) == instance_1 #=> false
  # Human.instance( :Joe ) == instance_2 #=> true
  # 
  def new *args, &block
    # Extract hash from args.
    oo = if args.last.is_a? Hash then args.pop else {} end
    # Swallow :name / :ɴ parameters.
    requested_name = oo.delete( :name ) || oo.delete( :ɴ )
    # Swallow :name! parameter.
    if oo[ :name! ] then
      fail ArgumentError, "Parameters :name! and :name (:ɴ) " +
        "cannot be supplied both at once!" if requested_name
      requested_name = oo.delete( :name! )
      exclamation_mark = true
    else
      exclamation_mark = false
    end
    # Prepare the arguments for instantiation.
    args << oo unless oo.empty?
    # Instantiate.
    instance = super *args, &block
    # Instantiation contract specifies that instances are created
    # unnamed. Thus, register the instance and set its name to nil.
    __instances__.update( instance => nil )
    # Instantiation contract specifies that instances are created
    # avid. Thus, make the instance avid.
    instance.send :make_avid!
    # Now, we have prepared the new instance nameless and avid
    # exactly according to the instantiation contract. Depending on
    # the arguments supplied to this method, the instance may soon
    # lose its avid state and get a name, but now, before any of
    # that happens, is the time to honor .instantiation_exec hook.
    honor_instantiation_exec( instance )
    # Return the instance if no name was requested for it.
    return instance unless requested_name
    # Now we know that a name was requested. The necessary action
    # depends on whether :name (:ɴ) or :name! parameter was used.
    # But already now, we know that the instance no longer needs
    # to be avid.
    instance.make_not_avid!
    # Depending on whether :name (:ɴ) or :name! was supplied...
    if exclamation_mark then
      # Name the instance aggresively.
      instance.name! requested_name
    else
      # Name the instance only if the name is not already in use.
      instance.name = requested_name
    end
    # Return the instance.
    return instance
  end

  private

  # Honors class'es hook .instantiation_exec. Takes one argument,
  # the newly constructed instance.
  # 
  def honor_instantiation_exec( instance )
    # Method #instantiation_exec, when called without a block,
    # returns the block defined earlier.
    block = instantiation_exec
    # Block is executed within the context of this class.
    instance_exec instance, &block
    # The method returns nil.
    return nil
  end

  # Backup of the #new method internals.

    # # Extract hash from args.
    # oo = if args.last.is_a? Hash then args.pop else {} end
    # # Swallow :name / :ɴ parameters.
    # requested_name = oo.delete( :name ) || oo.delete( :ɴ )
    # # Swallow :name! parameter.
    # if oo[ :name! ] then
    #   fail ArgumentError, "Parameters :name! and :name (:ɴ) " +
    #     "cannot be supplied both at once!" if requested_name
    #   fail ArgumentError, "When parameter :name! is used, :avid " +
    #     "must not be used!" if oo.keys.include? :avid
    #   requested_name = oo.delete( :name! )
    #   avid = true
    # else
    #   # Swallow :avid parameter.
    #   avid = oo.delete( :avid )      
    # end
    # # I think this is a program error. The construct below never
    # # executes, since in the first place it searches names in the
    # # array of instances.
    # # 
    # # # Avoid overwriting existing names unless avid:
    # # fail NameError, "#{self} instance named #{requested_name} " +
    # #   "already exists!" if __instances__.keys.include? nm unless avid
    # # Prepare the arguments for instantiation.
    # args << oo unless oo.empty?
    # # Instantiate.
    # new_instance = super *args, &block
    # # Instance construction contract specifies that the instances
    # # are created unnamed. Thus, enter the instance into the
    # # registry and set its name to nil.
    # __instances__.update( instance => nil )
    # # Instance construction contract specifies that the instances
    # # are created avid Make the instance avid. 
    
    # # Honor the #instantiation_exec hook.
    # honor_instantiation_exec( instance )


    # # Name the instance if name has been given.
    # if nm then
    #   # If name has been supplied, name the instance.
    #   avid ? instance.name!( nm ) : instance.name = nm
    # else # Name has not been given.
    #   # Make the instance avid unless expressly prohibited.
    #   __avid_instances__ << instance unless avid == false
    # end

    # # Return the constructed instance.
    # return new_instance
end # module NameMagic::ClassMethods
