# -*- coding: utf-8 -*-
require 'y_support'

# This mixin imitates Ruby constant magic and automates the named argument
# :name (alias :ɴ). One thus can write:
#
# <tt>class Someclass; include NameMagic end</tt>
# <tt>SomeName = SomeClass.new</tt>
#
# and the resulting object will know its #name:
#
# <tt>SomeName.name = "SomeName"</tt>
#
# This is done by searching the whole Ruby namespace for constants, to which
# the object might have been assigned. The search is performed by the method
# #const_magic defined by this mixin. Once the object is found to be assigned
# to a constant, and named accordingly, its subsequent assignments to other
# constants have no additional effect.
#
# Alternative way to create a named object is by specifying :name (alias :ɴ)
# named argument:
#
# <tt>SomeClass.new a, b, ..., name: "SomeName", aa: v1, bb: v2 ...</tt>
#
# Lastly, a name can be assigned by #name= accssor, as in
#
# <tt>o = SomeClass.new</tt>
# <tt>o.name = "SomeName"</tt>
#
# Hook is provided for when the name magic is performed, as well as when the
# name is retrieved.
# 
module NameMagic
  DEBUG = false

  def self.included ɱ
    case ɱ
    when Class then # we will decorate its #new method
      class << ɱ
        alias :original_method_new :new # Make space to decorate #new
      end
      # Attach the decorators etc.
      ɱ.extend ::NameMagic::ClassMethods
      ɱ.extend ::NameMagic::NamespaceMethods
      # Attach namespace methods also to the namespace, if given.
      begin
        if ɱ.namespace == ɱ then
          ɱ.define_singleton_method :namespace do ɱ end
        else
          ɱ.namespace.extend ::NameMagic::NamespaceMethods
        end
      rescue NoMethodError
      end
    else # it is a Module; we'll infect it with our #included method
      ɱ_included, this_included = ɱ.method( :included ), method( :included )
      ɱ.define_singleton_method :included do |ç|
        this_included.( ç )
        ɱ_included.( ç )
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
      name_get_closure ? name_get_closure.( ɴ ) : ɴ
    else nil end
  end
  alias ɴ name

  # Retrieves either an instance name (if present), or an object id.
  # 
  def name_or_object_id
    name || object_id
  end
  alias ɴ_ name_or_object_id

  # Names an instance, cautiously (ie. no overwriting of existing names).
  # 
  def name=( ɴ )
    puts "NameMagic: Naming with argument #{ɴ}." if DEBUG
    # get previous name of this instance, if any
    old_ɴ = self.class.__instances__[ self ]
    # honor the hook
    name_set_closure = self.class.instance_variable_get :@name_set_closure
    ɴ = name_set_closure.call( ɴ, self, old_ɴ ) if name_set_closure
    ɴ = self.class.send( :validate_capitalization, ɴ ).to_sym
    puts "NameMagic: Name adjusted to #{ɴ}." if DEBUG
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
    puts "NameMagic: Rudely naming with argument #{ɴ}." if DEBUG
    old_ɴ = self.class.__instances__[ self ] # get instance's old name, if any
    # honor the hook
    name_set_closure = self.class.instance_variable_get :@name_set_closure
    ɴ = name_set_closure.( ɴ, self, old_ɴ ) if name_set_closure
    ɴ = self.class.send( :validate_capitalization, ɴ ).to_sym
    puts "NameMagic: Name adjusted to #{ɴ}." if DEBUG
    return false if old_ɴ == ɴ # already named as required; nothing to do
    # otherwise, rudely remove the collider, if any
    pair = self.class.__instances__.rassoc( ɴ )
    self.class.__forget__( pair[0] ) if pair
    # and add self to the namespace instead
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
      __instances__.keys.select { |i| i.kind_of? self }
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
      namespace.instance_variable_get( :@instances ) ||
        namespace.instance_variable_set( :@instances, {} )
    end

    # Presents class-owned @avid_instances (no const_magic).
    # 
    def __avid_instances__
      namespace.instance_variable_get( :@avid_instances ) ||
        namespace.instance_variable_set( :@avid_instances, [] )
    end

    # Presents class-owned namespace. Normally, this is the class itself,
    # but can be overriden so as to define constants holding the instances
    # in some other module.
    # 
    def namespace
      self
    end

    # Makes the class use the namespace supplied as an argument.
    # 
    def namespace= namespc
      namespc.extend ::NameMagic::NamespaceMethods unless namespc == self
      tap { define_singleton_method :namespace do namespc end }
    end
      
    # Makes the class/module use itself as a namespace. (Useful eg. with
    # parametrized subclassing to tell the subclasses to maintain each their
    # own namespaces.)
    # 
    def namespace!
      self.namespace = self
    end

    # Returns the instance identified by the argument. NameError is raised, if
    # the argument does not identify an instance. (It can be an instance name
    # as string, symbol, or an instance itself, in which case, the instance in
    # question is merely returned without changes.)
    # 
    def instance arg
      # In @instances hash, name 'nil' means nameless!
      puts "NameMagic: #instance called with argument #{arg}." if DEBUG
      msg = "'nil' is not a valid argument type for NameMagic#instance method!"
      fail TypeError, msg if arg.nil?
      # if the argument is an actual instance, just return it
      ii = instances
      return arg if ii.include? arg
      # otherwise, assume arg is a name
      begin
        ii.find { |i| i.name == arg || i.name == arg.to_sym }
      rescue NoMethodError
      end or raise NameError, "No instance #{arg} in #{namespace}."
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
      todo = ( nameless_instances + __avid_instances__ ).map( &:object_id ).uniq
      ObjectSpace.each_object Module do |ɱ|     # for all the modules...
        # ( puts ɱ if DEBUG ) rescue
        ɱ.constants( false ).each do |const_ß|  # and all the constants...
          begin # insurance against constant dynamic loading fails
            ◉ = ɱ.const_get( const_ß )
          rescue LoadError, StandardError
            next
          end
          if todo.include? ◉.object_id then # we found a wanted object
            puts "NameMagic: Wanted object found under #{const_ß}." if DEBUG
            if __avid_instances__.map( &:object_id ).include? ◉.object_id # avid
              puts "NameMagic: It is avid." if DEBUG
              __avid_instances__ # 1. remove from avid list
                .delete_if { |instance| instance.object_id == ◉.object_id }
              ◉.name! const_ß    # 2. name rudely
            else # not avid
              puts "NameMagic: It is not avid." if DEBUG
              ɴ = if @name_set_closure then # honor name_set_closure
                    @name_set_closure.( const_ß, ◉, nil )
                      .tap { |r| puts "The resulting name is #{r}." }
                  else const_ß end
              ɴ = validate_capitalization( ɴ ).to_sym
              puts "NameMagic: Name adjusted to #{ɴ}." if DEBUG
              conflicter = begin # be cautious
                             namespace.const_get( ɴ )
                           rescue NameError
                           end
              if conflicter then
                puts "NameMagic: Conflicter exists named #{ɴ}." if DEBUG
                raise NameError, "Another #{self} named '#{ɴ}' already " +
                  "exists!" unless conflicter == ◉
              else
                puts "NameMagic: No conflicter named #{ɴ}, about to use it." if DEBUG
                __instances__[ ◉ ] = ɴ   # add the instance to the namespace
                namespace.const_set ɴ, ◉ # add the instance to the namespace
              end
            end
            todo.delete ◉.object_id # remove the id from todo list
            break if todo.empty?
          end
        end # each
      end # each_object Module
    end # def serve_all_modules

    # Checks whether a name starts with a capital letter.
    # 
    def validate_capitalization name
      ɴ = name.to_s
      # check whether the name starts with 'A'..'Z'
      raise NameError, "#{self.class} name must start with a capital " +
        " letter 'A'..'Z' ('#{ɴ}' was given)!" unless ( ?A..?Z ) === ɴ[0]
      return ɴ
    end
  end

  module ClassMethods
    # In addition to 'constant magic' ability (name upon constant assignment),
    # NameMagic redefines class method #new so that it eats parameter :name,
    # alias :ɴ, and takes care of naming the instance accordingly. Option
    # :name_avid can also be supplied (true/false), which makes the naming
    # avid if true. (Avid, or aggresive naming means that the instance being
    # named overwrites whatever was stored under that name earlier.)
    # 
    def new *args, &block
      oo = args[-1].is_a?( Hash ) ? args.pop : {} # extract hash
      ɴß = if oo[:name] then oo.delete :name # consume :name if supplied
           elsif oo[:ɴ] then oo.delete :ɴ    # consume :ɴ if supplied
           else nil end
      avid = oo[:name_avid] ? oo.delete( :name_avid ) : false # => true/false
      # Avoid overwriting existing names unless avid:
      raise NameError, "#{self} instance #{ɴß} already exists!" if
        __instances__.keys.include? ɴß unless avid
      # Instantiate:
      args << oo unless oo.empty?    # fuse hash
      new_inst = original_method_new *args, &block
      __instances__.merge! new_inst => nil # Instance is created unnamed
      # honor the hook
      @new_instance_closure.( new_inst ) if @new_instance_closure
      if ɴß then # name was supplied, name the instance
        if avid then new_inst.name! ɴß else new_inst.name = ɴß end
      else # name wasn't supplied, make the instance avid
        __avid_instances__ << new_inst
      end
      return new_inst      # return the new instance
    end

    # Calls #new in avid mode (name_avid: true).
    # 
    def new! *args, &block
      oo = args[-1].is_a?( Hash ) ? args.pop : {} # extract options
      new *args, oo.merge!( name_avid: true ), &block
    end
  end # module ClassMethods
end # module NameMagic
