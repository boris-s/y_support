# -*- coding: utf-8 -*-

module NameMagic::ClassMethods
  # Presents class-owned namespace. By default, this is the class itself, but
  # may be overriden to use some other module as a namespace.
  # 
  def namespace
    self
  end

  # Sets the namespace of the class.
  # 
  def namespace= modul
    modul.extend ::NameMagic::NamespaceMethods unless modul == self
    tap { define_singleton_method :namespace do modul end }
  end
      
  # Makes the class/module its own namespace. This is useful especially to tell
  # the subclasses of a class using NameMagic to maintain their own namespaces.
  # 
  def namespace!
    self.namespace = self
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
    original_method_new( *args, &block ).tap do |new_inst| # instantiate
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
  def new! *args, &block
    oo = args[-1].is_a?( Hash ) ? args.pop : {} # extract options
    new *args, oo.update( name_avid: true ), &block
  end
end # module NameMagic::ClassMethods
