#encoding: utf-8

class Object
  # === Support for typing by declaration

  # Class compliance inquirer.
  # 
  def declares_compliance?( mod )
    mod = mod.is_a?( Module ) ? mod.name.to_sym : mod.to_sym
    if self.class.name.to_sym == mod then return true # native type
    elsif declared_compliance.include?( mod ) then return true
    elsif begin
            self.singleton_class
          rescue TypeError
            self.class
          end.ancestors.any? { |ancest| ancest.name.to_sym == mod } then
      return true # implicit compliance through ancestry
    else return false end # none applies
  end
  
  # Class compliance pseudo-getter.
  # 
  def declared_compliance
    mods = instance_variable_get :@declared_compliance
    return [ self.class.name ] if mods.nil?
    raise "Unexpected @declared_compliance instance variable!" unless
      mods.include?( self.class.name.to_sym )
    return mods
  end
  
  # Declaration of module / class compliance.
  # 
  def declare_compliance!( *modules )
    modules.each do |symbol_or_module|
      names = case symbol_or_module
              when Module then
                symbol_or_module.ancestors.map( &:name ).map( &:to_sym )
              else [ symbol_or_module.to_sym ] end
      instance_variable_set :@declared_compliance,
                            ( declared_compliance() + names ).uniq
    end
  end

  # === Duck typing support (aka. runtime assertions)

  # This method takes a block and fails with TypeError, unless the receiver
  # fullfills the block criterion. Optional arguments customize customize
  # the error message. First optional argument describes the receiver, the
  # second one describes the tested duck type. If the criterion block takes
  # at least one argument, the receiver is passed to it. If the criterion block
  # takes no arguments (arity 0), it is executed inside the singleton class of
  # the receiver (using #instance_exec method). If no block is given, it is
  # checked, whether the object is truey.
  # 
  def tE what_is_receiver=nil, how_comply=nil, &b
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    if block_given?
      m = "#{r} fails #{ how_comply ? 'to %s' % how_comply : 'its duck type' }!"
      raise TErr, m unless ( b.arity == 0 ) ? instance_exec( &b ) : b.( self )
    else
      m = "#{r} is nil of false!"
      raise TErr, m unless self
    end
    return self
  end
  
  # This method takes a block and fails with TypeError, unless the receiver
  # causes the supplied block <em>to return falsey value</em>. Optional arguments
  # customize customize the error message. First optional argument describes the
  # receiver, the second one describes the tested duck type. If the criterion
  # block takes at least one argument (or more arguments), the receiver is passed
  # to it. If the criterion block takes no arguments (arity 0), it is executed
  # inside the singleton class of the receiver (using #instance_exec method). If
  # no block is given, it is checked, whether the object is falsey.
  # 
  def tE_not what_is_receiver=nil, how_comply=nil, &b
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    if block_given?
      m = how_comply ? "#{r} must not #{how_comply}!" :
        "#{r} fails its duck type!"
      raise TErr, m if ( b.arity == 0 ) ? instance_exec( &b ) : b.( self )
    else
      m = "#{r} is not falsey!"
      raise TErr, m if self
    end
    return self
  end

  # Fails with TypeError unless the receiver is of the prescribed class. Second
  # optional argument customizes the error message (receiver description).
  # 
  def tE_kind_of klass, what_is_receiver=nil
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    m = "#{r} is not a kind of #{klass}!"
    raise TErr, m unless kind_of? klass
    return self
  end
  alias :tE_is_a :tE_kind_of

  # Fails with TypeError unless the receiver declares compliance with the
  # given class, or is a descendant of that class. Second optional argument
  # customizes the error message (receiver description).
  # 
  def tE_declares_compliance klass, what_is_receiver=nil
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    m = "#{r} does not declare compliance to #{klass}!"
    raise TErr, m unless declares_compliance? klass
    return self
  end
  
  # Fails with TypeError unless the receiver responds to the given
  # method. Second optional argument customizes the error message (receiver
  # description).
  # 
  def tE_respond_to method_name, what_is_receiver=nil
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    m = "#{r} does not respond to method '#{method_name}'!"
    raise TErr, m unless respond_to? method_name
    return self
  end
  
  # Fails with TypeError unless the receiver, according to #== method, is
  # equal to the argument. Two more optional arguments customize the error
  # message (receiver description and the description of the other object).
  # 
  def tE_equal other, what_is_receiver=nil, what_is_other=nil
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    o = what_is_other || "the prescribed value (#{other.class})"
    m = "#{r} is not equal (==) to #{o}!"
    raise TErr, m unless self == other
    return self
  end
  
  # Fails with TypeError unless the receiver, according to #== method, differs
  # from to the argument. Two more optional arguments customize the error
  # message (receiver description and the description of the other object).
  # 
  def tE_not_equal other, what_is_receiver=nil, what_is_other=nil
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    o = what_is_other || "the prescribed value (#{other.class})"
    m = "#{r} fails to differ from #{o}!"
    raise TErr, m if self == other
    return self
  end
  
  # Fails with TypeError unless the ActiveSupport method #blank returns true
  # for the receiver.
  # 
  def tE_blank what_is_receiver=nil
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    m = "#{r} fails to be #blank?!"
    raise TErr, m unless blank?
    return self
  end
  
  # Fails with TypeError unless the ActiveSupport method #present returns true
  # for the receiver.
  # 
  def tE_present what_is_receiver=nil
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    m = "#{r} fails to be #present?!"
    raise TErr, m unless present?
    return self
  end
end
