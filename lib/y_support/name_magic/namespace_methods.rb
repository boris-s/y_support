# encoding: utf-8

module NameMagic
  module NamespaceMethods
    # Presents the instances registered in this namespace.
    #
    def instances *args
      const_magic
      __instances__.keys
    end

    # Presents the instance names registered in this namespace.
    #
    def instance_names *args
      instances.names( false )
    end

    # Presents namespace-owned +@instances+ hash. The hash consists of pairs
    # <code>{ instance => instance_name }</code>. Unnamed instances have +nil+
    # assigned to them as their name. (The method does not trigger
    # +#const_magic+.)
    #
    def __instances__ *args
      @instances ||= {}
    end

    # Avid instances registered in this namespace. ("Avid" means that the
    # instance is able to steal (overwrite) a name from another registered
    # instance. (The method does not trigger +#const_magic+.)
    #
    def __avid_instances__ *args
      @avid_instances ||= []
    end

    # Returns the instance identified by the argument, which can be typically
    # a name (string/symbol). If a registered instance is supplied, it will be
    # returned unchanged.
    #
    def instance id, *args
      # puts "#instance( #{identifier} )" if DEBUG
      # In @instances hash, value 'nil' indicates a nameless instance!
      fail TypeError, "'nil' is not an instance identifier!" if id.nil?
      ii = instances
      return id if ii.include? id # return the instance back
      begin # identifier not a registered instace -- treat it as a name
        ary = [id, id.to_sym]
        ii.find { |inst| ary.include? inst.name }
      rescue NoMethodError
      end or fail NameError, "No instance #{id} in #{self}."
    end

    # Searches all the modules in the the object space for constants containing
    # receiver class objects, and names the found instances accordingly. The
    # number of the remaining nameless instances is returned.
    #
    def const_magic
      puts "#{self}#const_magic invoked!" if ::NameMagic::DEBUG
      return 0 if nameless_instances.size == 0
      serve_all_modules
      return nameless_instances.size
    end
    
    # Returns those instances, which are nameless (whose name is set to nil).
    # 
    def nameless_instances *args
      __instances__.select { |key, val| val.nil? }.keys
    end

    # Clears namespace-owned references to a specified instance. (This is
    # different from "unnaming" an instance by setting <code>inst.name =
    # nil</code>, which makes the instance anonymous, but still registered.)
    # 
    def forget instance_identifier, *args
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
    def __forget__( instance, *args )
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

    # Clears namespace-owned references to all the instances.
    # 
    def forget_all_instances
      __instances__.clear           # clears @instances
      constants( false ).each { |ß| # clear constants in the namespace
        namespace.send :remove_const, ß if const_get( ß ).is_a? self
      }
    end

    # Registers a hook to execute upon instantiation. Expects a unary block, whose
    # argument represents the new instance. It is called right after instantiation,
    # but before naming the instance.
    # 
    def new_instance_hook &block
      @new_instance_hook = block if block
      @new_instance_hook ||= -> instance { instance }
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
      @name_set_hook = block if block
      @name_set_hook ||= -> name, instance, old_name=nil { name }
    end

    # Registers a hook to execute whenever the instance is asked its name. The
    # instance names are objects that are kept in a hash referred to by
    # +@instances+ variable owned by the namespace. Normally, +NameMagic#name+
    # simply returns the name of the instance, as found in the +@instances+ hash.
    # When +name_get_hook+ is defined, this name is transformed by it before being
    # returned.
    # 
    def name_get_hook &block
      @name_get_hook = block if block
      @name_get_hook ||= -> name { name }
    end

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
          # puts "NameMagic: Anonymous object under #{const_ß}!" if DEBUG
          if ◉.avid? then # puts "NameMagic: It is avid." if DEBUG
            ◉.make_not_avid!    # 1. Remove it from the list of avid instances.
            ◉.name! const_ß     # 2. Name it rudely.
          else # puts "NameMagic: It is not avid." if DEBUG
            ɴ = validate_name( name_set_hook.( const_ß, ◉, nil ) ).to_sym
            # puts "NameMagic: Name adjusted to #{ɴ}." if DEBUG
            conflicter = begin; const_get( ɴ ); rescue NameError; end
            if conflicter then
              msg = "Another #{self}-registered instance named '#{ɴ}' exists!"
              fail NameError, msg unless conflicter == ◉
            else # add the instance to the namespace
              __instances__.update( ◉ => ɴ )
              const_set( ɴ, ◉ )
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
