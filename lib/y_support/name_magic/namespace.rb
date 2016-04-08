# encoding: utf-8

# Module methods for the modules serving as +NameMagic+
# namespaces. What is a +NameMagic+ namespace? For a class that
# includes +NameMagic+, namespace is the "civil registry" of all
# instances, both named and nameless. For this purpose, namespace
# has variable +@instances+. The registry of instances is a hash of
# pairs <tt>{ instance => name }</tt>. Nameless instances have
# _nil_ value instead of name in the registry. In general Ruby,
# namespace would mean that the module holds the instances in
# constants looking like <tt>Namespace::Name</tt>. In Ruby core, we
# can see such behavior with Struct class, which has native
# constant magic and stores its instances in constants using Struct
# as a namespace. NameMagic used to perform this constant
# assignment in the namespace prior to YSupport version ~2.0.  This
# is one of the reasons why names of instances must start with a
# capital letter and be usable as constant names. Since YSupport
# version 2.0+, NameMagic does no constant assignment on its own --
# all constant assignments are left to the user. In this way,
# NameMagic now sees constant assignment purely as a way to learn
# instance names intended by the user.
#
# The instance registry is accessible via +#instances+
# method. Individual instances can be queried for by +#instance+
# method, eg. by their names.  Until Matz provides the possibility
# of constant magic in every class, which I requested some time
# ago, the registry of instances will remain the essential part,
# without which +NameMagic wouldn't work.
# 
# === Life cycle of instances of +NameMagic+ user classes
#
# Let us consider for example Human class that uses NameMagic.
# 
# class Human
#   require 'y_support/name_magic'
#   include NameMagic
# end
# 
# Life cycle of Human in instances of begins, unsurprisingly, by
# instantiation.  All instances are created nameless:
# 
# newborn = Human.new
# newborn.name #=> nil
# 
# User has several ways of naming the instances. Typical for
# +NameMagic+ is naming by constant assignment:
# 
# Fred = newborn
# newborn.name #=> :Fred
# 
# +NameMagic makes it possible to supply :name parameter directly
# to the #new method. Such instances are named immediately:
# 
# newborn = Human.new name: "Joe"
# newborn.name #=> :Joe
# 
# Another way is to name the instances using #name= method.
# 
# newborn = Human.new
# newborn.name #=> nil
# newborn.name = "Mike"
# newborn.name #=> Mike
# 
# Just for the record, we have created three instances:
# 
# Human.instances #=> [Fred, Joe, Mike]
# 
# In other words, at some point in their life, instances may or may
# not undergo baptism, which involves a complicated procedure of
# searching all existing Ruby modules for constants to which
# nameless instances of the class in question are
# assigned. Baptized instances then know their names, and can be
# accessed by their names through the instance registry:
# 
# Human.instance( "Mike" ) #=> Mike
# 
# Namespace gives the user 2 hook methods, #instantiation_exec and
# #exec_when_naming. The first one is executed upon instantiation
# and passed one argument, the new instance. The second one is
# executed when the namespace baptizes a new instance, and passed
# three arguments: suggested name, instance, and previous name if
# any. (Renaming instances may require special care.) Consequantly,
# you should define unary block with #instantiation_exec and
# ternary one with #exec_when_naming. Example:
# 
# Human.instantiation_exec do |instance|
#   puts "Instance with object id #{instance.object_id} created!"
# end
# newborn = Human.new #=> Instance with object id 75756140 created!
# 
# The naming hook can also be used to censor and modify the
# intended name. Consider the following censorship:
# 
# Human.exec_when_naming do |name, instance, old_name|
#   fail NameError, "#{name.capitalize} is not a saint in the " +
#     "Church of Emacs!" unless name.end_with? "gnucius"
#   "St_IGNUcius"
# end
# 
# Now we can no longer use ordinary names, we have to use names of
# saints in the Church of Emacs!
# 
# newborn.name = "Dave"
# #=> NameError: Dave is not a saint in the Church of Emacs!
# 
# Name Ignucius is OK, but the censor corrects it to St_IGNUcius:
# 
# newborn.name = "Ignucius" #=> St_IGNUcius
# 
# Life cycle of an instance ends when it is deleted from the
# instance registry and garbage-collected (unless something else
# holds a reference to it). Example:
# 
# Human.instances #=> [Fred, Joe, Mike, St_IGNUcius]
# Human.forget "St_IGNUcius"
# Human.instances #=> [Fred, Joe, Mike]
# 
# St. IGNUcius has just been deleted from the registry.
# 
# Human.forget_all_instances
# Human.instances #=> []
# 
# All Human instances have now been deleted from the registry, but
# only Joe and Mike are garbage-collected, because Fred is still
# assigned to a constant. Fred still exists, but he and his name
# has been deleted from the instance registry.
# 
# Fred #=> #<Human:0x89449b0>
# 
# We could even re-register Fred by recreating his entry, although
# this is far from the way +NameMagic+ works in everyday life.
# 
# Human.__instances__.merge! Fred => :Fred
# Human.instances #=> [Fred]
#
# === Avidity of the instances 
#
# After the offered name is checked and modified by the name set
# hook closure, there is one more remaining problem to worry about:
# Whether the name is already used by another instance in the same
# namespace. If the name is taken, the ensuing action depends on
# whether the instance being named is _avid_.  Avid instances are
# so eager to get a name, that they will steal the offered name for
# themselves even if other instances already use the name, making
# the conflicting instance nameless in the process. In +NameMagic+,
# it turns out to be convenient to make the new instances avid by
# default, unless the name was explicitly supplied to the
# constructor by +:name+ argument, or avidity suppressed by setting
# +:name_avid option to _false_.
#
# Techincally, avid instances are registered as an array kept by
# the namespace under the variable +@avid_instances+.
#
# === Forgetting instances
#
# As mentioned earlier, namespace can de-register, or forget
# instances. For this purpose, see methods +#forget+, +#__forget__,
# +#forget_nameless_instances+, +#forget_all_instances+.
#
# === Ersatz constant magic
# 
# To imitate built-in constant magic of some Ruby classes,
# +NamespaceMethods+ provides ersatz method +#const_magic+, that
# searches all the modules in the object space for the pertinent
# instances newly assigned to constants. Method +#const_magic+ is
# called automatically before executing almost every public method
# of +NameMagic+, thus keeping the "civil registry"
# up-to-date. While not exactly computationally efficient, it tends
# to make the user code more readable and pays off in most
# usecases. For efficiency, we are looking forward to the
# +#const_assigned+ hook promised by Ruby core team...
#
# The namespace method versions that _do_ _not_ perform ersatz
# constant magic are generally denoted by underlines: Eg. methods
# +#__instances__+ and +#__forget__+ do not perform constant magic,
# while +#instances+ and +#forget+ do.
# 
module NameMagic::Namespace
  # Orders the namespace to disallow unnaming instances. As a
  # consequence, the instances' names will now be permanent.
  # 
  def permanent_names!
    @permanent_names = true
  end

  # Inquirer whether unnaming instances has been disallowed in
  # the namespace.
  #
  def permanent_names?
    @permanent_names
  end

  # Presents the instances registered in this namespace.
  #
  def instances *args
    const_magic
    __instances__.keys
  end

  # Presents namespace-owned +@instances+ hash. The hash consists
  # of pairs <code>{ instance => instance_name }</code>. Unnamed
  # instances have +nil+ value instead of their name. This method
  # does not trigger +#const_magic+.
  #
  def __instances__
    @instances ||= {}
  end

  # Avid instances registered in this namespace. ("Avid" means that
  # the instance will steal (overwrite) a name from another
  # instance, should there be a conflict. The method does not
  # trigger +#const_magic+.
  #
  def __avid_instances__
    @avid_instances ||= []
  end

  # Returns the instance identified by the argument.
  #
  def instance arg
    # In @instances hash, nil value denotes nameless instances!
    fail TypeError,
         "Nil is not an instance identifier!" if arg.nil?
    # Get the list of all instances.
    ii = instances
    # If arg belongs to the list, just return it back.
    return arg if ii.include? arg
    # Assume that arg is an instance name.
    name = arg.to_sym
    registry = __instances__
    ii.find { |i| registry[ i ] == name } or
      fail NameError, "No instance #{arg} in #{self}!"
  end

  # Searches all the modules in the the object space for constants
  # referring to receiver class objects, and names the found
  # instances accordingly.  Internally, it works by invoking
  # private procedure +#search_all_modules.  The return value is
  # the remaining number of nameless instances.
  #
  def const_magic
    return 0 if nameless_instances.size == 0
    search_all_modules
    return nameless_instances.size
  end
    
  # Returns those instances, whose name is nil. This method does
  # not trigger #const_magic.
  # 
  def nameless_instances *args
    __instances__.select { |key, val| val.nil? }.keys
  end

  # Removes the specified instance from the registry. Note that
  # this is different from "unnaming" an instance by setting
  # <code>inst.name = nil</code>, which makes the instance
  # anonymous, but still registered.
  # 
  def forget instance, *args
    instance = begin
                 instance instance
               rescue ArgumentError
                 return nil # nothing to forget
               end
    ɴ = instance.nil? ? nil : instance.name
    # namespace.send :remove_const, ɴ if ɴ
    __instances__.delete( instance )
    __avid_instances__.delete( instance )
    return instance
  end

  # Removes the specified instance from the registry, without
  # performing #const_magic first. The argument should be a
  # registered instance. Returns instance name for forgotten named
  # instances, _nil_ for forgotten nameless instances, and _false_
  # if the argument was not a registered instance.
  # 
  def __forget__ instance
    return false unless __instances__.keys.include? instance
    # namespace.send :remove_const, instance.name if instance.name
    __avid_instances__.delete( instance )
    __instances__.delete instance
  end

  # Removes all anonymous instances from the registry.
  # 
  def forget_nameless_instances
    const_magic # #nameless_instances doesn't trigger it
    nameless_instances.each { |instance|
      __instances__.delete( instance )
      __avid_instances__.delete( instance )
    }
  end

  # Clears references to all the instances.
  # 
  def forget_all_instances
    instances.map { |instance| __forget__ instance }
    # constants( false ).each { |sym|
    #   namespace.send :remove_const, sym if
    #     const_get( sym ).is_a? self }
  end

  # Registers a block to execute when a new instance of the
  # +NameMagic+ user class is created. (In other words, this method
  # provides user class'es instantiation hook.) Expects a unary
  # block, whose argument is the new instance. Return value of the
  # block is unimportant. The block will be executed in the context
  # of the user class. If no block is given, the method returns the
  # previously defined block, if any, or a default block that does
  # nothing.
  # 
  def instantiation_exec &block
    @instantiation_exec = block if block
    @instantiation_exec ||= -> instance { }
  end
  # Note: This alias must stay while the dependencies need it.
  alias new_instance_hook instantiation_exec

  # Registers a block to execute just prior to naming of an
  # instance. (In other words, this method provides user class'es
  # naming hook.) The block will be executed in the context of the
  # user class and will be supplied three ordered arguments:
  # suggested name, instance, and previous name. The block should
  # thus be written as ternary, expecting these three arguments.
  # The block can be used to validate / censor the suggested name
  # and for this reason, it should return the censored name that
  # will actually be requested for the instance. (Of course, just
  # like there is no duty to use this hook, if you do use it, there
  # is likewise no duty to censor the suggested name in it. You can
  # just return the suggested name unchanged from the block.) The
  # point is that the return value of the block will actually be
  # used to name the instance. If no block is given, the method
  # returns the previously defined block, if any, or a default
  # block that does nothing and returns the suggested name without
  # any changes.
  # 
  def exec_when_naming &block
    @exec_when_naming = block if block
    @exec_when_naming ||=
      -> name, instance, previous_name=nil { name }
  end
  # Note: This alias must stay while the dependencies need it.
  alias name_set_hook exec_when_naming

  # Registers a block to execute just prior to unnaming of an
  # instance. (In other words, this method provides user class'es
  # unnaming hook.) The block will be executed in the context of
  # the user class and will be supplied two ordered arguments:
  # instance and its previous name. The block can thus be written
  # as up to binary. Return value of the block is unimportant. If
  # no block is given, the method returns the block defined
  # earlier, if any, or a default block that does nothing.
  # 
  def exec_when_unnaming &block
    @exec_when_unnaming = block if block
    @exec_when_unnaming ||= -> instance, previous_name=nil { }
  end

  # Checks whether a name is acceptable as a constant name.
  # 
  def validate_name name
    # Note that the #try method (provided by 'y_support/literate')
    # allows us to call the methods of name without mentioning
    # it explicitly as the receiver, and it also allows us to
    # raise errors without explicitly constructing the error
    # messages. Thus, chars.first actually means name.chars.first.
    # Error message (when error occurs) is constructed from
    # the #try description and the #note strings, which act at
    # the same time as code comments. End of advertisement for
    # 'y_support/literate'.
    # 
    name.to_s.try "to validate the suggested instance name" do
      note "rejecting non-capitalized names"
      fail NameError unless ( ?A..?Z ) === chars.first
      note "rejecting names with spaces"
      fail NameError if chars.include? ' '
    end
    # Return value is the validated name.
    return name
  end

  private

  # Searches all modules for user class instances.
  # 
  def search_all_modules
    # Set up the list of object ids to search. These are ids
    # of all unnamed registered instances.
    todo = ( nameless_instances + __avid_instances__ )
             .map( &:object_id )
             .uniq
    # Browse all modules in the deep ObjectSpace for those ids.
    ObjectSpace.each_object Module do |ɱ|
      ɱ.constants( false ).each do |const_ß|
        # Some constants cause unexpected problems. The line
        # below is the result of trial-and-error programming
        # and I am afraid to delete it quite yet.
        next if ɱ == Object && const_ß == :Config
        # Those constants that raise certain errors upon attempts
        # to access their contents are handled by this
        # begin-rescue-end statement.
        begin
          instance = ɱ.const_get( const_ß )
        rescue LoadError, StandardError
          next # go on to the next constant
        end
        # We now go on to the next iteration of the loop if the
        # constant which we are checking does not refer to the
        # object with id we are searching for.
        next unless todo.include? instance.object_id
        # At this point, we have ascertained that the constant
        # we are looking at contains unnamed instance.
        if instance.avid? then
          begin
            # Name it rudely.
            instance.name! const_ß
          ensure
            # Remove the "avid" flag from the instance.
            instance.make_not_avid!
          end
        else
          # Avid flag is not set, name the instance politely.
          # 
          # Note that instances of NameMagic user classes are
          # created avid. So if the anonymous instance is not
          # avid at this point, it means it must have lost its
          # avidity either being a previously named and now
          # unnamed instance, or by the user explicitly invoking
          # its #make_not_avid! method. In the first case, we do
          # not want to see NameErrors raised ad infinitum just
          # because there is some now-unnamed instance assigned
          # to some forgotten constant in the deep namespace.
          # In the second case, we must assume that the user
          # takes the responsibility. So we will swallow NameError
          # here:
          begin
            instance.name = const_ß
          rescue NameError
          end
        end
        # Remove the instance object id from todo list.
        todo.delete instance.object_id
        # Quit looping once todo list is empty.
        break if todo.empty?
      end
    end
  end
end # module NameMagic::NamespaceMethods
