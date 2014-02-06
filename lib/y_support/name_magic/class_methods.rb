# encoding: utf-8

# Class methods for the classes that include NameMagic.
# 
module NameMagic::ClassMethods
  # Presents the instances registered by the namespace. Takes one optional
  # argument. If set to _false_, the method returns all the instances
  # registered by the namespace. If set to _true_ (default), only returns
  # those instances registered by the namespace, which are of exactly the
  # same class as the receiver. Example:
  # 
  # <code>
  # class Animal; include NameMagic end
  # Cat, Dog = Class.new( Animal ), Class.new( Animal )
  # Spot = Dog.new
  # Livia = Cat.new
  # Animal.instances #=> returns 2 instances (2 animals)
  # Dog.instances #=> returns 1 instance (only 1 is of Dog subclass)
  # Dog.instances( false ) #=> 2 instances again (all the animals)
  # </code>
  #
  def instances option=true
    return super if namespace == self
    ii = namespace.instances
    option ? ii.select { |i| i.kind_of? self } : ii
  end

  # Deprecated method to get full names of the named instances. Takes one
  # optional argument, same as +#instances+ method.
  #
  def instance_names option=true
    warn "Method #instance_names( option ) is deprecated. Use % instead!" %
      '"instances( option ).names" or "instances( option )._names_"'
    instances( option ).names( false )
  end

  # Presents namespace-owned +@instances+ hash. The hash consists of pairs
  # <code>{ instance => instance_name }</code>. Unnamed instances have +nil+
  # assigned to them as their name. (The method does not trigger
  # +#const_magic+.)
  # 
  def __instances__
    return super if namespace == self
    namespace.__instances__
  end

  # Presents namespace-owned +@avid_instances+ (array of avid instances). "Avid"
  # means that the instance is able to overwrite a name used by another
  # registered instance. (This method does not trigger +#const_magic+.)
  # 
  def __avid_instances__
    return super if namespace == self
    namespace.__avid_instances__
  end

  # Returns the instance identified by the first argument, which can typically
  # be a name (string/symbol). If a registered instance is supplied, it is
  # returned without change. The second argument is optional, with the same
  # meaning as in +NameMagic::ClassMethods#instances+ method.
  # 
  def instance id, option=true
    return super if namespace == self
    namespace.instance( id ).tap { |inst|
      fail NameError, "No #{self} instance #{id} registered in " +
        "#{namespace}!" unless inst.kind_of? self if option
    }
  end

  # Searches all the modules in the the object space for constants containing
  # receiver class objects, and names the found instances accordingly. The
  # number of the remaining nameless instances is returned.
  #
  def const_magic
    return super if namespace == self
    namespace.const_magic
  end

  # Returns the nameless instances. The optional argument has the same meaning
  # as in +NameMagic::ClassMethods#instances+ method.
  # 
  def nameless_instances option=true
    return super if namespace == self
    ii = namespace.nameless_instances
    option ? ii.select { |i| i.kind_of? self } : ii
  end

  # Clears namespace-owned references to a specified instance. (This is
  # different from "unnaming" an instance by setting <code>inst.name =
  # nil</code>, which makes the instance anonymous, but still registered.)
  # 
  def forget instance_identifier, option=true
    if namespace == self || ! option then super else
      namespace.forget instance( instance_identifier )
    end
  end

  # Clears namespace-owned references to an instance, without performing
  # #const_magic first. The argument should be a registered instance. Returns
  # the instance name, or _false_, if there was no such registered instance.
  # 
  def __forget__( instance, option=true )
    return super if namespace == self
    fail NameError, "Supplied argument not an instance of #{self}!" unless
      instance.is_a? self if option
    namespace.__forget__ instance
  end

  # Clears namespace-owned references to all the anonymous instances.
  # 
  def forget_nameless_instances
    return super if namespace == self
    namespace.forget_nameless_instances
  end

  # Clears namespace-owned references to all the instances.
  # 
  def forget_all_instances
    return super if namespace == self
    namespace.forget_all_instances
  end

  # Registers a hook to execute upon instantiation. Expects a unary block, whose
  # argument represents the new instance. It is called right after instantiation,
  # but before naming the instance.
  # 
  def new_instance_hook &block
    return super if namespace == self
    namespace.new_instance_hook &block
  end

  # Registers a hook to execute upon instance naming. Expects a ternary block,
  # with arguments instance, name, old_name, representing respectively the
  # instance to be named, the requested name, and the previous name of that
  # instance (if any). The output of the block should be the name to actually
  # be used. In other words, the hook can be used (among other things) to check
  # and/or modify the requested name when christening the instance. It is the
  # responsibility of this block to output a symbol that can be used as a Ruby
  # constant name.
  # 
  def name_set_hook &block
    return super if namespace == self
    namespace.name_set_hook &block
  end

  # Registers a hook to execute whenever the instance is asked its name. The
  # instance names are objects that are kept in a hash referred to by
  # +@instances+ variable owned by the namespace. Normally, +NameMagic#name+
  # simply returns the name of the instance, as found in the +@instances+ hash.
  # When +name_get_hook+ is defined, this name is transformed by it before being
  # returned.
  # 
  def name_get_hook &block
    return super if namespace == self
    namespace.name_get_hook &block
  end

  # Sets the namespace for the class.
  # 
  def namespace= modul
    puts "Assigning #{modul} as the namespace of #{self}." if ::NameMagic::DEBUG 
    modul.extend ::NameMagic::NamespaceMethods
    define_singleton_method :namespace do modul end
  end

  # Sets the namespace for the class to self.
  # 
  def namespace!
    nil.tap { self.namespace = self }
  end

  # In addition the ability to name objects upon constant assignment, as common
  # with eg. Class instances, NameMagic redefines class method #new so that it
  # swallows the named argument :name (alias :ɴ), and takes care of naming the
  # instance accordingly. Also, :name_avid named argument mey be supplied, which
  # makes the naming avid (able to overwrite the name already in use by
  # another object) if set to _true_.
  # 
  def new *args, &block
    oo = if args[-1].is_a? Hash then args.pop else {} end  # extract hash
    nm = oo.delete( :name ) || oo.delete( :ɴ )   # consume :name / :ɴ if given
    avid = oo.delete( :name_avid )
    # Avoid overwriting existing names unless avid:
    fail NameError, "#{self} instance #{nm} already exists!" if
      __instances__.keys.include? nm unless avid
    args << oo unless oo.empty?    # prepare the arguments
    super( *args, &block ).tap do |inst| # instantiate
      __instances__.update( inst => nil ) # Instances are created unnamed...
      namespace.new_instance_hook.tap { |λ|
        λ.( inst ) if λ
        if nm then # Name supplied, name the instance.
          avid ? inst.name!( nm ) : inst.name = nm
        else # Name not given, make the inst. avid unless expressly prohibited.
          __avid_instances__ << inst unless avid == false
        end
      }
    end
  end

  # Calls #new in _avid_ _mode_ (<tt>name_avid: true</tt>); see #new method for
  # avid mode explanation.
  # 
  def avid *args, &block
    oo = args[-1].is_a?( Hash ) ? args.pop : {} # extract options
    new *args, oo.update( name_avid: true ), &block
  end

  private

  # Checks all the constants in some module's namespace, recursively.
  # 
  def serve_all_modules
    return super if namespace == self
    namespace.serve_all_modules
  end

  # Performs general name validation.
  # 
  def validate_name name
    return super if namespace == self
    namespace.validate_name name
  end
end # module NameMagic::ClassMethods
