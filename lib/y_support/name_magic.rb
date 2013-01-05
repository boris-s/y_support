#encoding: utf-8
require 'y_support'

# A mixin imitating Ruby constant magic, plus automation of :name alias :ɴ
# named argument. This allows to write:
#
# <tt>SomeName = SomeClass.new</tt>
#
# and the resulting object will know its #name:
#
# <tt>SomeName.name = "SomeName"</tt>
#
# This is done by searching the whole Ruby namespace for constants to which
# the object is assigned. The search is performed by calling #const_magic.
# This is only done until the name is found - once the object is named, its
# subsequent assignment to constants is without effect.
#
# Alternatively, a named object can be created by using :name alias :ɴ
# named argument:
#
# SomeName.new arg1, arg2, ..., name: "SomeName", named_arg1: val1, ...
#
# Hook is provided for when the name magic is performed.
# 
module NameMagic
  DEBUG = false
  PROBLEM_MODULES = [ 'Gem', 'Rack', 'ActiveSupport' ]

  def self.included target
    case target
    when Class then
      class << target
        # Make space for the decorator #new:
        alias :original_method_new :new
      end
      # Attach the decorators etc.
      target.extend ::NameMagic::ClassMethods
      target.extend ::NameMagic::NamespaceMethods
      # Attach namespace methods to also to the namespace, if given.
      begin
        unless target == target.namespace
          target.namespace.extend ::NameMagic::NamespaceMethods
        end
      rescue NoMethodError
      end
    else # it is a Module; we'll infect it with this #included method
      included_of_the_target = target.method( :included )
      included_of_self = self.method( :included )
      pre_included_of_the_target = begin
                                     target.method( :pre_included )
                                   rescue NameError
                                   end
      if pre_included_of_the_target then
        target.define_singleton_method :included do |ç|
          pre_included_of_the_target.( ç )
          included_of_self.call( ç )
          included_of_the_target.call( ç )
        end
      else
        target.define_singleton_method :included do |ç|
          included_of_self.( ç )
          included_of_the_target.( ç )
        end
      end
    end
  end # self.included

  # Retrieves an instance name (demodulized).
  # 
  def name
    self.class.const_magic
    ɴ = self.class.__instances__[ self ]
    if ɴ then
      name_get_closure = self.class.instance_variable_get :@name_get_closure
      return name_get_closure ? name_get_closure.( ɴ ) : ɴ
    else
      return nil
    end
  end
  alias ɴ name

  # Names an instance, cautiously (ie. no overwriting of existing names).
  # 
  def name=( ɴ )
    # get previous name of this instance, if any
    old_ɴ = self.class.__instances__[ self ]
    # honor the hook
    name_set_closure = self.class.instance_variable_get :@name_set_closure
    ɴ = name_set_closure.call( ɴ, self, old_ɴ ) if name_set_closure
    ɴ = self.class.send( :validate_capitalization, ɴ ).to_sym
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
    # get previous name of this instance, if any
    old_ɴ = self.class.__instances__[ self ]
    # honor the hook
    name_set_closure = self.class.instance_variable_get :@name_set_closure
    ɴ = name_set_closure.( ɴ, self, old_ɴ ) if name_set_closure
    ɴ = self.class.send( :validate_capitalization, ɴ ).to_sym
    return false if old_ɴ == ɴ # already named as required; nothing to do
    # otherwise, rudely remove the collider, if any
    pair = self.class.__instances__.rassoc( ɴ )
    self.class.__forget__( pair[0] ) if pair
    # and add add self to the namespace
    self.class.namespace.const_set ɴ, self # write a constant
    self.class.__instances__[ self ] = ɴ   # write to __instances__
    self.class.__forget__ old_ɴ            # forget the old name of self
    return true
  end

  module NamespaceMethods
    # Presents class-owned @instances hash of { instance => name } pairs.
    # 
    def instances
      const_magic
      __instances__.keys
    end

    # Presents an array of all the instance names (disregarding anonymous
    # instances).
    # 
    def instance_names
      instances.map( &:name ).compact
    end

    # Presents class-owned @instances without const_magic.
    # 
    def __instances__
      namespace.instance_variable_get( :@instances ) or
        namespace.instance_variable_set( :@instances, {} )
    end

    # Presents class-owned @avid_instances (no const_magic).
    # 
    def __avid_instances__
      namespace.instance_variable_get( :@avid_instances ) or
        namespace.instance_variable_set( :@avid_instances, [] )
    end

    # Presents class-owned namespace. Normally, this is the class itself,
    # but can be overriden so as to define constants holding the instances
    # in some other module.
    # 
    def namespace
      self
    end

    # Returns the instance of the class using NameMagic, specified by the
    # argument. NameError is raised, if the argument does not represent a valid
    # instance name, or if the argument itself is not a valid instance (in
    # which case it is returned unchanged).
    # 
    def instance arg
      const_magic
      # if the argument is an actual instance, just return it
      return arg if __instances__.keys.include? arg
      # otherwise, treat it as name
      r = begin
            __instances__.rassoc( arg ) || __instances__.rassoc( arg.to_sym )
          rescue NoMethodError
          end or
        raise NameError, "No instance #{arg} in #{namespace}."
      return r[0]
    end


    # The method will search all the modules in the the object space for
    # receiver class objects assigned to constants, and name these instances
    # accordingly. Number of the remaining nameless instances is returned.
    # 
    def const_magic
      return 0 if nameless_instances.size == 0
      serve_all_modules
      return nameless_instances.size
    end # def const_magic

    # Returns those instances, which are nameless (@instances hash value is nil).
    # 
    def nameless_instances
      __instances__.select { |key, val| val.nil? }.keys
    end

    # Clears class-owned references to a specified instance.
    # 
    def forget( which_instance )
      inst = begin
               instance( which_instance )
             rescue ArgumentError
               return nil            # nothing to forget
             end
      ɴ = inst.nil? ? nil : inst.name
      namespace.send :remove_const, ɴ if ɴ # clear constant assignment
      __instances__.delete( inst )   # remove @instances entry
      __avid_instances__.delete( inst ) # remove if any
      return inst                            # return forgotten instance
    end

    # Clears class-owned references to a specified instance without performing
    # #const_magic first. The argument must be an instance of the target class.
    # 
    def __forget__( instance )
      name = __instances__.delete instance # remove @instances entry
      __avid_instances__.delete( instance ) # remove if any
      namespace.send :remove_const, name if name
      return instance
    end

    # Clears class-owned references anonymous instances.
    # 
    def forget_anonymous_instances
      nameless_instances.each { |inst, ɴ|
        __instances__.delete inst
        __avid_instances__.delete inst
      }
    end
    alias :forget_nameless_instances :forget_anonymous_instances
    
    # Clears class-owned references to all the instances.
    # 
    def forget_all_instances
      __instances__.clear           # clears @instances
      constants( false ).each { |ß| # clear constants in the namespace
        namespace.send :remove_const, ß if const_get( ß ).is_a? self
      }
    end
    
    # Registers a hook to execute whenever name magic creates a new instance
    # of the class including NameMagic. The block should take one argument
    # (the new instance that was created) and is called in #new method right
    # after instantiation, but before naming.
    # 
    def new_instance_closure &block; @new_instance_closure = block end

    # Registers a hook to execute whenever name setting is performed on an
    # instance. The block should take three arguments (instance, name, old_name).
    # The output value of the block is the name to be actually used – the hook
    # thus allows to define transformations on the name when naming. It is the
    # responsibility of the block to output a suitable symbol (capitalized,
    # usable as a constant name etc.)
    # 
    def name_set_closure &block; @name_set_closure = block end

    # Registers a hook to execute whenever the instance is asked about its
    # name. The name object contained in __instances__[self] is subjected
    # to the name_get_closure before being returned as instance name.
    # 
    def name_get_closure &block; @name_get_closure = block end

    private
    
    # Checks all the constants in some module's namespace, recursively.
    # 
    def serve_all_modules
      incriminated_ids = ( nameless_instances + __avid_instances__ )
        .map( &:object_id ).uniq
      ObjectSpace.each_object Module do |ɱ|
        # hack against bugs when getting constants from URI
        next if ::NameMagic::PROBLEM_MODULES.any? { |problem_ς|
          ɱ.name.to_s.start_with? problem_ς
        }
        puts ɱ if ::NameMagic::DEBUG
        # check all the module constants:
        ɱ.constants( false ).each do |const_ß|
          begin # insurance against buggy dynamic loading of constants
            ◉ = ɱ.const_get( const_ß )
          rescue
            next
          end
          # is it a wanted object?
          if incriminated_ids.include? ◉.object_id then
            if __avid_instances__.map( &:object_id ).include? ◉.object_id then
              # name avidly
              __avid_instances__.delete_if { |instance| # make not avid first
                instance.object_id == ◉.object_id
              }
              ◉.name! const_ß      # and then name it rudely
            else # name this anonymous instance cautiously
              # honor name_set_closure
              ɴ = if @name_set_closure then
                    @name_set_closure.( const_ß, ◉, nil )
                  else const_ß end
              ɴ = validate_capitalization( ɴ ).to_sym
              conflicter = begin # be cautious
                             namespace.const_get( ɴ )
                           rescue NameError
                           end
              if conflicter then
                raise NameError, "Another #{self} named '#{ɴ}' already " +
                  "exists!" unless conflicter == ◉
              else
                # add the instance to the namespace
                __instances__[ ◉ ] = ɴ
                namespace.const_set ɴ, ◉
              end
            end
            # and stop working in case there are no more unnamed instances
            incriminated_ids.delete ◉.object_id
            break if incriminated_ids.empty?
          end
        end # each
      end # each_object Module
    end # def serve_all_modules

    # Checks whether a name starts with a capital letter.
    # 
    def validate_capitalization( name )
      ɴ = name.to_s
      # check whether the name starts with 'A'..'Z'
      raise NameError, "#{self.class} name must start with a capital " +
        " letter 'A'..'Z' ('#{ɴ}' was given)!" unless ( ?A..?Z ) === ɴ[0]
      return ɴ
    end
  end

  module ClassMethods
    # In addition to its ability to assign name to the target instance when
    # the instance is assigned to a constant (aka. constant magic), NameMagic
    # redefines #new class method to consume named parameter :name, alias :ɴ,
    # thus providing another option for naming of the target instance.
    # 
    def new *args, &block
      # extract options:
      if args[-1].is_a? Hash then oo = args.pop else oo = {} end
      # consume :name named argument if it was supplied
      ɴß = if oo[:name] then oo.delete :name
           elsif oo[:ɴ] then oo.delete :ɴ
           else nil end
      # Expecting true/false, if :name_avid option is given
      avid = oo[:name_avid] ? oo.delete( :name_avid ) : false
      # Avoid name collisions unless avid
      raise NameError, "#{self} instance #{ɴß} already exists!" if
        __instances__.keys.include? ɴß unless avid
      # instantiate
      args = if oo.empty? then args else args + [ oo ] end
      new_inst = if oo.empty? then original_method_new *args, &block
                 else original_method_new *args, oo, &block end
      # treat is as unnamed at first
      __instances__.merge! new_inst => nil
      # honor the hook
      @new_instance_closure.call( new_inst ) if @new_instance_closure
      # and then either name it, if name was supplied, or make it avid
      # (avid instances will replace a competitor, if any, in the name table)
      if ɴß then
        if avid then new_inst.name! ɴß else new_inst.name = ɴß end
      else
        __avid_instances__ << new_inst
      end
      # return the new instance
      return new_inst
    end

    # Compared to #new method, #new! uses avid mode: without
    # concerns about overwriting existing named instances.
    # 
    def new! *args, &block
      # extract options
      if args[-1].is_a? Hash then oo = args.pop else oo = {} end
      # and call #new with added name_avid: true
      new *args, oo.merge!( name_avid: true )
    end
  end # module ClassMethods
end # module NameMagic
