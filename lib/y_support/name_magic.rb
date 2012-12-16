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
    raise NameError, "#{self.class} instance #{ɴ} already exists!" if
      self.class.__instances__.rassoc( ɴ )
    # if everything's ok., add self to the namespace
    self.class.const_set ɴ, self
    self.class.__instances__[ self ] = ɴ.to_s
    # and forget the old name
    self.class.forget old_ɴ
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
    self.class.__instances__[ self ] = ɴ.to_s
    # and forget the old name
    self.class.forget old_ɴ
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
      return which if ( @instances ||= {} ).keys.include? which
      inst = @instances.rassoc( which.to_s )
      raise ArgumentError, "No instance #{which} in #{self}" if inst.nil?
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
      # Expecting true/false, if :name_angry option is given
      aggressive = oo[:name_aggressive] ? oo.delete( :name_aggressive ) : false
      # Avoid name collisions unless aggressive
      raise NameError, "#{self} instance #{ɴς} already exists!" if
        ( @instances ||= {} ).keys.include? ɴς unless aggressive
      # instantiate
      new_inst = if oo.empty? then super *args, &block
                 else super *args, oo, &block end
      # treat is as unnamed at first
      ( @instances ||= {} ).merge! new_inst => nil
      # and then either name it, if name was supplied, or make it aggressive
      if ɴς then
        if aggressive then new_inst.name! ɴς else new_inst.name = ɴς end
      else
        ( @name_aggressive_instances ||= [] ) << new_inst
      end
      # honor the hook
      @name_magic_hook.call( new_inst ) if @name_magic_hook
      # return the new instance
      return new_inst
    end

    # Compared to #new method, #new! uses name_aggressive mode: without
    # concerns about overwriting existing named instances.
    # 
    def new! *args, &block
      # extract options
      if args[-1].is_a? Hash then oo = args.pop else oo = {} end
      # and call #new with added name_aggressive: true
      new *args, oo.merge!( name_aggressive: true )
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
               return nil
             end
      ɴ = inst.nil? ? nil : inst.name
      send :remove_const, ɴ if ɴ # clear constant assignment
      ( @instances ||= {} ).delete( inst )   # remove @instances entry
      ( @name_aggressive_instances ||= [] ).delete( inst ) # remove if any
      return inst                            # return forgotten instance
    end

    # Clears class-owned references anonymous instances.
    # 
    def forget_anonymous_instances
      nameless_instances.each { |inst, ɴ|
        @instances.delete inst
        @name_aggressive_instances.delete inst
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
    
    # Registers a hook to execute whenever name magic is performed on a new
    # instance (in #new method also provided by this module).
    # 
    def name_magic_hook &block; @name_magic_hook = block end

    private
    
    # Checks all the constants in some module's namespace, recursively
    def serve_all_modules
      incriminated_ids = 
        ( nameless_instances + ( @name_aggressive_instances ||= [] ) )
        .map( &:object_id ).uniq
      ObjectSpace.each_object Module do |ɱ|
        # check all the module constants:
        ɱ.constants( false ).each do |const_ß|
          ◉ = ɱ.const_get( const_ß ) rescue nil
          # is it a wanted object?
          if incriminated_ids.include? ◉.object_id then
            if @name_aggressive_instances.include? ◉ then # name aggressively
              @name_aggressive_instances.delete ◉
              ◉.name! const_ß
            else # name this anonymous instance cautiously
              if ( @instances ||= {} )[ ◉ ] or const_get const_ß then
                raise NameError, "Name '#{const_ß}' already exists in " +
                  "#{self.class} namespace!"
              end
              # if everything's ok., add the instance to the namespace
              @instances[ ◉ ] = const_ß.to_s
              const_set const_ß, ◉
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
