# -*- coding: utf-8 -*-
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
  def self.included receiver         # :nodoc:
    class << receiver
      alias :original_method_new :new
    end
    receiver.extend NameMagicClassMethods
  end

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
  def name=( name )
    ɴ = self.class.send :validate_name, name
    # get previous name of this instance, if any
    old_ɴ = name()
    # honor the hook
    name_set_closure = self.class.instance_variable_get :@name_set_closure
    if name_set_closure then
      ɴ = self.class.send :validate_name_set_closure_return_value,
                          name_set_closure.call( ɴ, self, old_ɴ )
    end
    ɴ = self.class.send :validate_name_starts_with_capital_letter, ɴ
    # do nothing if previous name same as the new one
    return if old_ɴ == ɴ
    # otherwise, continue by being cautious about name collisions
    raise NameError, "Name '#{ɴ}' already exists in " +
      "#{self.class} namespace!" if self.class.__instances__.rassoc( ɴ )
    # if everything's ok., add self to the namespace
    self.class.const_set ɴ, self
    self.class.__instances__[ self ] = ɴ
    # forget the old name
    self.class.__forget__ old_ɴ
  end

  # Names an instance, aggresively (overwrites existing names).
  # 
  def name!( name )
    ɴ = self.class.send :validate_name, name
    # get previous name of this instance, if any
    old_ɴ = self.class.__instances__[ self ]
    # honor the hook
    name_set_closure = self.class.instance_variable_get :@name_set_closure
    if name_set_closure then
      ɴ = self.class.send :validate_name_set_closure_return_value,
                          name_set_closure.call( ɴ, self, old_ɴ )
    end
    ɴ = self.class.send :validate_name_starts_with_capital_letter, ɴ
    # do nothing if the previous name same as the new one
    return false if old_ɴ == ɴ
    # otherwise, continue by forgetting the colliding name, if any
    if pair = self.class.__instances__.rassoc( ɴ ) then
      self.class.__forget__( pair[0] )
    end
    # add self to the namespace
    self.class.const_set ɴ, self
    self.class.__instances__[ self ] = ɴ
    # forget the old name
    self.class.__forget__ old_ɴ
    return true
  end

  module NameMagicClassMethods
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
      return @instances ||= {}
    end

    # Presents class-owned @avid_instances (no const_magic).
    # 
    def __avid_instances__
      return @avid_instances ||= []
    end

    def instance which
      puts "Hello from #instance method"
      const_magic
      # if 'which' is an actual instance, just return it
      return which if __instances__.keys.include? which
      # otherwise check the argument class
      case which
      when String, Symbol then
        inst = __instances__.rassoc( which.to_sym )
        raise NameError, "No instance #{which} in #{self}." if inst.nil?
      else
        raise TypeError, "No instance #{which.class}:'#{which}' in #{self}."
      end
      return inst[0]
    end

    # In addition to its ability to assign name to the target instance when
    # the instance is assigned to a constant (aka. constant magic), NameMagic
    # redefines #new class method to consume named parameter :name, alias :ɴ,
    # thus providing another option for naming of the target instance.
    # 
    def new *args, &block
      # extract options:
      if args[-1].is_a? Hash then oo = args.pop else oo = {} end
      # consume :name named argument if it was supplied
      ɴß = if oo[:name] then validate_name( oo.delete :name )
           elsif oo[:ɴ] then validate_name( oo.delete :ɴ )
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

    # The method will search the namespace for constants, to which the nameless
    # instances of the receiver class are assigned, and name these instances
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
      send :remove_const, ɴ if ɴ # clear constant assignment
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
      send :remove_const, name if name
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
      __instances__.clear          # clears @instances
      constants( false )           # clear constant assignments in the class
        .each { |ß| send :remove_const, ß if const_get( ß ).is_a? self }
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
        next if ɱ.name.include? "URI"
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
                    validate_name_set_closure_return_value @name_set_closure
                      .call( const_ß, ◉, nil )
                  else const_ß end
              ɴ = validate_name_starts_with_capital_letter( ɴ )
              if const_get( ɴ ) then
                raise NameError, "Another #{self} named '#{ɴ}' already " +
                  "exists!" unless const_get( ɴ ) == ◉ 
              else
                # add the instance to the namespace
                __instances__[ ◉ ] = ɴ
                const_set ɴ, ◉
              end
            end
            # and stop working in case there are no more unnamed instances
            incriminated_ids.delete ◉.object_id
            break if incriminated_ids.empty?
          end
        end # each
      end # each_object Module
    end # def serve_all_modules

    # Checks whether a name is valid. Takes in the tentative name, and returns
    # its validated version (a symbol).
    # 
    def validate_name( tentative_name )
      begin
        ɴ = tentative_name.to_sym
      rescue NoMethodError
        raise ArgumentError, "Argument (class #{tentative_name.class}) " +
          "cannot be validated as name!"
      end
    end

    # Checks whether the return value of name_set_closure is o.k. Takes one
    # argument – the return value – and returns the validated return value.
    # 
    def validate_name_set_closure_return_value( raw_return_value )
      begin
        return raw_return_value.to_sym
      rescue
        raise "Bad name_set_closure block - it returns a " +
          "#{raw_return_value.class} instead of a name. The block should " +
          "take up to 3 arguments (name, instance, old_name) and is " +
          "expected to return the transformed name. The main purpose " +
          "of this hook is to enable name transformations. If no " +
          "transformation is desired, the block – if used – must return the " +
          "name unchanged."
      end
    end

    # Checks whether a name starts with a capital letter.
    def validate_name_starts_with_capital_letter( ɴ )
      # check whether the name starts with 'A'..'Z'
      raise NameError, "#{self.class} name must start with a capital letter " +
        "'A'..'Z'! (Name '#{ɴ}' was supplied)" unless ( ?A..?Z ) === ɴ.to_s[0]
      return ɴ.to_sym
    end
  end # module NameMagicClassMethods
end # module NameMagic
