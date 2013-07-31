# -*- coding: utf-8 -*-

module NameMagic::ClassMethods
  # Presents the instances registered by the namespace. Takes one optional
  # argument. If set to _false_, the method returns all the instances
  # registered by the namespace. If set to _true_ (default), only returns
  # those instances registered by the namespace, which are of the exact same
  # class as the method's receiver. Example:
  #
  #   class Animal; include NameMagic end
  #   Cat, Dog = Class.new( Animal ), Class.new( Animal )
  #   Spot = Dog.new
  #   Livia = Cat.new
  #   Animal.instances #=> returns 2 instances
  #   Dog.instances #=> returns 1 instance
  #   Dog.instances( false ) #=> returns 2 instances of the namespace Animal
  #
  def instances option=false
    const_magic
    return __instances__.keys if option
    __instances__.keys.select { |i| i.kind_of? self }
  end

  # Presents the instance names. Takes one optional argument, same as
  # #instances method. Unnamed instances are completely disregarded.
  #
  def instance_names option=false
    instances( option ).names( false )
  end

  # In addition the ability to name objects upon constant assignment, as common
  # with eg. Class instances, NameMagic redefines class method #new so that it
  # swallows the named argument :name (alias :ɴ), and takes care of naming the
  # instance accordingly. Also, :name_avid named argument mey be supplied, which
  # makes the naming avid (able to overwrite the name already in use by
  # another object) if set to _true_.
  # 
  def new *args, &block
    oo = args[-1].is_a?( Hash ) ? args.pop : {} # extract hash
    nm = if oo[:name] then oo.delete :name       # consume :name if supplied
         elsif oo[:ɴ] then oo.delete :ɴ          # consume :ɴ if supplied
         else nil end
    avid = oo[:name_avid] ? oo.delete( :name_avid ) : false # => true/false
    # Avoid overwriting existing names unless avid:
    fail NameError, "#{self} instance #{nm} already exists!" if
      __instances__.keys.include? nm unless avid
    args << oo unless oo.empty?    # prepare the arguments
    new_before_name_magic( *args, &block ).tap do |new_inst| # instantiate
      __instances__.update new_inst => nil # Instance is created unnamed...
      namespace.new_instance_closure.tap { |λ|
        λ.( new_inst ) if λ
        if nm then # name has been supplied, we can name the instance:
          avid ? new_inst.name!( nm ) : new_inst.name = nm
        else # name hasn't been supplied, making the instance avid:
          __avid_instances__ << new_inst
        end
      }
    end
  end

  # Calls #new in _avid_ _mode_ (name_avid: true); see #new method for avid mode
  # explanation.
  # 
  def avid *args, &block
    oo = args[-1].is_a?( Hash ) ? args.pop : {} # extract options
    new *args, oo.update( name_avid: true ), &block
  end
end # module NameMagic::ClassMethods
