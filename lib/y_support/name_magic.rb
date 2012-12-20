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

module NameMagic
  def self.included receiver         # :nodoc:
    receiver.extend NameMagicClassMethods
  end

  # Retrievs an instance name (demodulized).
  # 
  def name
    self.class.const_magic
    return nil unless ɴ = self.class.instances[ self ]
    return ɴ
  end
  alias ɴ name

  # Names an instance, cautiously (ie. no overwriting of existing names).
  # 
  def name=( name )
    ɴ = self.class.send :validate_name, name
    # get previous name of this instance, if any
    old_ɴ = name()
    # do nothing if previous name same as the new one
    return if old_ɴ == ɴ
    # otherwise, continue by being cautious about name collisions
    raise NameError, "Name '#{ɴ}' already exists in " +
      "#{self.class} namespace!" if self.class.__instances__.rassoc( ɴ )
    # if everything's ok., add self to the namespace
    self.class.const_set ɴ, self
    self.class.__instances__[ self ] = ɴ.to_sym
    # forget the old name
    self.class.forget old_ɴ
    # and honor the hook
    naming_hook = self.class.instance_variable_get :@naming_hook
    naming_hook.call( self, const_ß, old_ɴ ) if naming_hook
  end

  # Names an instance, aggresively (overwrites existing names).
  # 
  def name!( name )
    ɴ = self.class.send :validate_name, name
    # get previous name of this instance, if any
    old_ɴ = self.class.__instances__[ self ]
    # do noting if previous name same as the new one
    return false if old_ɴ == ɴ
    # otherwise, continue by forgetting the colliding name, if any
    same_ɴ_inst = self.class.instance( ɴ ) rescue nil
    self.class.forget same_ɴ_inst if same_ɴ_inst
    # add self to the namespace
    self.class.const_set ɴ, self
    self.class.__instances__[ self ] = ɴ.to_sym
    # forget the old name
    self.class.forget old_ɴ
    # honor the hook
    naming_hook = self.class.instance_variable_get :@naming_hook
    naming_hook.call( self, const_ß, old_ɴ ) if naming_hook
    return true
  end

  module NameMagicClassMethods
    # Presents class-owned @instances hash of { instance => name_string }
    # pairs.
    # 
    def instances
      const_magic
      __instances__
    end

    # Presents class-owned @instances without const_magic.
    # 
    def __instances__
      return @instances ||= {}
    end

    def instance which
      const_magic
      # if 'which' is an actual instance, just return it
      return which if __instances__.keys.include? which
      # otherwise check the argument class
      case which
      when String, Symbol then
        inst = @instances.rassoc( which.to_sym )
        raise ArgumentError, "No instance #{which} in #{self}" if inst.nil?
      else
        raise ArgumentError, "No instance #{which} (#{which.class}) in #{self}"
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
      ɴς = if oo[:name] then validate_name( oo.delete :name )
           elsif oo[:ɴ] then validate_name( oo.delete :ɴ )
           else nil end
      # Expecting true/false, if :name_avid option is given
      avid = oo[:name_avid] ? oo.delete( :name_avid ) : false
      # Avoid name collisions unless avid
      raise NameError, "#{self} instance #{ɴς} already exists!" if
        ( @instances ||= {} ).keys.include? ɴς unless avid
      # instantiate
      new_inst = if oo.empty? then super *args, &block
                 else super *args, oo, &block end
      # treat is as unnamed at first
      ( @instances ||= {} ).merge! new_inst => nil
      # honor the hook
      @new_instance_hook.call( new_inst ) if @new_instance_hook
      # and then either name it, if name was supplied, or make it avid
      # (avid instances will replace a competitor, if any, in the name table)
      if ɴς then
        if avid then new_inst.name! ɴς else new_inst.name = ɴς end
      else
        ( @name_avid_instances ||= [] ) << new_inst
      end
      # return the new instance
      return new_inst
    end

    # Compared to #new method, #new! uses name_avid mode: without
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
      ( @instances ||= {} ).select { |key, val| val.nil? }.keys
    end

    # Clears class-owned references to a specified instance.
    # 
    def forget( instance )
      inst = begin
               instance( instance )
             rescue ArgumentError
               return nil            # nothing to forget
             end
      ɴ = inst.nil? ? nil : inst.name
      send :remove_const, ɴ if ɴ # clear constant assignment
      ( @instances ||= {} ).delete( inst )   # remove @instances entry
      ( @name_avid_instances ||= [] ).delete( inst ) # remove if any
      return inst                            # return forgotten instance
    end

    # Clears class-owned references anonymous instances.
    # 
    def forget_anonymous_instances
      nameless_instances.each { |inst, ɴ|
        @instances.delete inst
        @name_avid_instances.delete inst
      }
    end
    alias :forget_nameless_instances :forget_anonymous_instances
    
    # Clears class-owned references to all the instances.
    # 
    def forget_all_instances
      @instances = {}                # clear @instances
      constants( false )             # clear constant assignments in the class
        .each { |ß| send :remove_const, ß if const_get( ß ).is_a? self }
    end
    
    # Registers a hook to execute whenever name magic creates a new instance
    # of the class including NameMagic. The block should take one argument
    # (the new instance that was created) and is called in #new method right
    # after instantiation, but before naming.
    # 
    def new_instance_hook &block; @new_instance_hook = block end

    # Registers a hook to execute whenever naming is performed on an instance.
    # The block should take three arguments (instance, name, old_name).
    # 
    def naming_hook &block; @naming_hook = block end

    private
    
    # Checks all the constants in some module's namespace, recursively
    def serve_all_modules
      incriminated_ids = 
        ( nameless_instances + ( @name_avid_instances ||= [] ) )
        .map( &:object_id ).uniq
      ObjectSpace.each_object Module do |ɱ|
        # check all the module constants:
        ɱ.constants( false ).each do |const_ß|
          ◉ = ɱ.const_get( const_ß ) rescue nil
          # is it a wanted object?
          if incriminated_ids.include? ◉.object_id then
            if @name_avid_instances.include? ◉ then # name avidly
              @name_avid_instances.delete ◉
              ◉.name! const_ß
            else # name this anonymous instance cautiously
              raise NameError, "Name '#{const_ß}' already exists in " +
                "#{self.class} namespace!" if
                  __instances__[ ◉ ] || const_get( const_ß )
              # if everything's ok., add the instance to the namespace
              __instances__[ ◉ ] = const_ß
              const_set const_ß, ◉
              # honor naming_hook
              @naming_hook.call( ◉, const_ß, nil ) if @naming_hook
            end
            # and stop working in case there are no more unnamed instances
            incriminated_ids.delete ◉.object_id
            break if incriminated_ids.empty?
          end
        end # each
      end # each_object Module
    end # def serve_all_modules

    # Checks whether a name is valid
    def validate_name( name )
      ɴ = name.to_s
      # check whether the name starts with 'A'..'Z'
      raise NameError, "#{self.class} name must start with a capital letter " +
        "'A'..'Z'! (Name '#{ɴ}' was supplied)" unless ( ?A..?Z ) === ɴ[0]
      return ɴ
    end
  end # module NameMagicClassMethods
end # module NameMagic
