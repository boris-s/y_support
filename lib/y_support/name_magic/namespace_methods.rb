# -*- coding: utf-8 -*-

module NameMagic
  module NamespaceMethods
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
      nil.tap { self.namespace = self }
    end

    # Presents the instances registered by the namespace.
    #
    def instances
      const_magic
      __instances__.keys
    end

    # Presents the instance names. Takes one optional argument, same as
    # #instances method. Unnamed instances are completely disregarded.
    #
    def instance_names
      instances.names( false )
    end

    # Presents namespace-owned @instances hash of pairs <code>{ instance =>
    # instance_name }</code>. Unnamed instances have nil value. (Also, this
    # method does not trigger #const_magic.)
    #
    def __instances__
      namespace.instance_variable_get( :@instances ) ||
        namespace.instance_variable_set( :@instances, {} )
    end

    # Presents namespace-owned @avid_instances array of avid instances. "Avid"
    # means that the instance is able to overwrite a name used by another
    # registered instance. (Also, this method does not trigger const_magic).
    #
    def __avid_instances__
      namespace.instance_variable_get( :@avid_instances ) ||
        namespace.instance_variable_set( :@avid_instances, [] )
    end

    # Returns the instance identified by the argument. NameError is raised, if
    # the argument does not identify an instance. (It can be an instance name
    # (string/symbol), or an instance itself, in which case, it is just returned
    # back without changes.)
    #
    def instance identifier
      puts "#instance( #{identifier} )" if DEBUG
      # In @instances hash, value 'nil' indicates a nameless instance!
      fail TypeError, "'nil' is not an instance identifier!" if identifier.nil?
      ii = instances
      return identifier if ii.include? identifier # return the instance back
      begin # identifier not a registered instace -- treat it as a name
        ary = [identifier, identifier.to_sym]
        ii.find do |i| ary.include? i.name end
      rescue NoMethodError
      end or raise NameError, "No instance #{identifier} in #{self}."
    end

    # Searches all the modules in the the object space for constants containing
    # receiver class objects, and names the found instances accordingly. The
    # number of the remaining nameless instances is returned.
    #
    def const_magic
      return 0 if nameless_instances.size == 0
      serve_all_modules
      return nameless_instances.size
    end # def const_magic

    # Returns those instances, which are nameless (whose name is set to nil).
    # 
    def nameless_instances
      __instances__.select { |key, val| val.nil? }.keys
    end
    alias unnamed_instances nameless_instances
    alias anonymous_instances nameless_instances

    # Clears namespace-owned references to a specified instance. (This is
    # different from "unnaming" an instance by setting <code>inst.name =
    # nil</code>, which makes the instance anonymous, but still registered.)
    # 
    def forget( instance_identifier )
      inst = begin
               instance( instance_identifier )
             rescue ArgumentError
               return nil            # nothing to forget
             end
      ɴ = inst.nil? ? nil : inst.name
      namespace.send :remove_const, ɴ if ɴ   # clear constant assignment
      __instances__.delete( inst )           # remove @instances entry
      __avid_instances__.delete( inst )      # remove if any
      return inst                            # return the forgotten instance
    end

    # Clears namespace-owned references to an instance, without performing
    # #const_magic first. The argument should be a registered instance. Returns
    # the instance name, or _false_, if there was no such registered instance.
    # 
    def __forget__( instance )
      return false unless __instances__.keys.include? instance
      namespace.send :remove_const, instance.name if instance.name
      __avid_instances__.delete( instance )
      __instances__.delete instance
    end

    # Clears namespace-owned references to all the anonymous instances.
    # 
    def forget_nameless_instances
      nameless_instances.each { |inst, ɴ|
        __instances__.delete inst
        __avid_instances__.delete inst # also from here
      }
    end
    alias forget_unnamed_instances forget_nameless_instances
    alias forget_anonymous_instances forget_nameless_instances

    # Clears namespace-owned references to all the instances.
    # 
    def forget_all_instances
      __instances__.clear           # clears @instances
      constants( false ).each { |ß| # clear constants in the namespace
        namespace.send :remove_const, ß if const_get( ß ).is_a? self
      }
    end

    # Registers a hook to execute whenever name magic creates a new instance of
    # the class including NameMagic. The block should take one argument (the new
    # instance that was created) and is called in #new method right after
    # instantiation, but before naming.
    # 
    def new_instance_closure &block
      namespace.new_instance_closure &block unless namespace == self
      @new_instance_closure = block if block
      @new_instance_closure ||= -> instance { instance }
    end
    alias new_instance_hook new_instance_closure

    # Registers a hook to execute whenever name setting is performed on an
    # instance. The block should take three arguments (instance, name, old_name).
    # The output value of the block is the name to be actually used – the hook
    # thus allows to define transformations on the name when naming. It is the
    # responsibility of the block to output a suitable symbol (capitalized,
    # usable as a constant name etc.)
    # 
    def name_set_closure &block
      namespace.name_set_closure &block unless namespace == self
      @name_set_closure = block if block
      @name_set_closure ||= -> name, instance, old_name=nil { name }
    end
    alias name_set_hook name_set_closure

    # Registers a hook to execute whenever the instance is asked about its
    # name. The name object contained in __instances__[self] is subjected
    # to the name_get_closure before being returned as instance name.
    # 
    def name_get_closure &block
      namespace.name_get_closure &block unless namespace == self
      @name_get_closure = block if block
      @name_get_closure ||= -> name { name }
    end
    alias name_get_hook name_get_closure

    private

    # Checks all the constants in some module's namespace, recursively.
    # 
    def serve_all_modules
      todo = ( nameless_instances + __avid_instances__ ).map( &:object_id ).uniq
      ObjectSpace.each_object Module do |ɱ|
        ɱ.constants( false ).each do |const_ß|
          begin
            ◉ = ɱ.const_get( const_ß ) # insurance against const. loading fails
          rescue LoadError, StandardError; next end
          next unless todo.include? ◉.object_id
          puts "NameMagic: Anonymous object under #{const_ß}!" if DEBUG
          if __avid_instances__.map( &:object_id ).include? ◉.object_id # avid
            puts "NameMagic: It is avid." if DEBUG
            __avid_instances__       # 1. remove from avid list
              .delete_if { |inst| inst.object_id == ◉.object_id }
            ◉.name! const_ß          # 2. name rudely
          else puts "NameMagic: It is not avid." if DEBUG # not avid
            ɴ = validate_name( name_set_closure.( const_ß, ◉, nil ) ).to_sym
            puts "NameMagic: Name adjusted to #{ɴ}." if DEBUG
            conflicter = begin; namespace.const_get( ɴ ); rescue NameError; end
            if conflicter then
              msg = "Another #{self}-registered instance named '#{ɴ}' exists!"
              fail NameError, msg unless conflicter == ◉
            else # add the instance to the namespace
              __instances__.update( ◉ => ɴ )
              namespace.const_set( ɴ, ◉ )
            end
          end
          todo.delete ◉.object_id # remove the id from todo list
          break if todo.empty?    # and break the loop if done
        end # each
      end # each_object Module
    end # def serve_all_modules

    # Checks whether a name starts with a capital letter.
    # 
    def validate_name name
      name.to_s.tap do |ɴ| # check whether the name starts with 'A'..'Z'
        fail NameError, "#{self}-registered name must start with a capital " +
        " letter 'A'..'Z' ('#{ɴ}' given)!" unless ( ?A..?Z ) === ɴ[0]
      end
    end
  end # module NamespaceMethods
end # module NameMagic
