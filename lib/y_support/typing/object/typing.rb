#encoding: utf-8

require 'active_support/core_ext/object/blank'

class Object
  # === Support for typing by declaration

  # Class compliance inquirer (declared compliance + class ancestors).
  # 
  def class_complies?( klass )
    singleton_class_or_class.complies? klass
  end

  # Declared class compliance.
  # 
  def class_declares_compliance?( klass )
    singleton_class_or_class.declares_compliance? klass
  end

  # Class compliance (declared class compliance + ancestors).
  # 
  def class_compliance
    singleton_class_or_class.compliance
  end

  # Declared class compliance.
  # 
  def declared_class_compliance
    singleton_class_or_class.declared_compliance
  end

  # Declaration of class compliance.
  # 
  def declare_class_compliance!( klass )
    singleton_class_or_class.declare_compliance! klass
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
  def aT what_is_receiver=nil, how_comply=nil, &b
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    if block_given?
      m = "#{r} fails #{how_comply ? 'to %s' % how_comply : 'its duck type'}!"
      raise TErr, m unless ( b.arity == 0 ) ? instance_exec( &b ) : b.( self )
    else
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
  def aT_not what_is_receiver=nil, how_comply=nil, &b
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
  def aT_kind_of klass, what_is_receiver=nil
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    m = "#{r} is not a kind of #{klass}!"
    raise TErr, m unless kind_of? klass
    return self
  end
  alias :aT_is_a :aT_kind_of

  # Fails with TypeError unless the receiver declares compliance with the
  # given class, or is a descendant of that class. Second optional argument
  # customizes the error message (receiver description).
  # 
  def aT_class_complies klass, what_is_receiver=nil
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    m = "#{r} does not comply or declare compliance with #{klass}!"
    raise TErr, m unless class_complies? klass
    return self
  end
  
  # Fails with TypeError unless the receiver responds to the given
  # method. Second optional argument customizes the error message (receiver
  # description).
  # 
  def aT_respond_to method_name, what_is_receiver=nil
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    m = "#{r} does not respond to method '#{method_name}'!"
    raise TErr, m unless respond_to? method_name
    return self
  end
  alias :aT_responds_to :aT_respond_to
  
  # Fails with TypeError unless the receiver, according to #== method, is
  # equal to the argument. Two more optional arguments customize the error
  # message (receiver description and the description of the other object).
  # 
  def aT_equal other, what_is_receiver=nil, what_is_other=nil
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
  def aT_not_equal other, what_is_receiver=nil, what_is_other=nil
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
  def aT_blank what_is_receiver=nil
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    m = "#{r} fails to be #blank?!"
    raise TErr, m unless blank?
    return self
  end

  # Fails with TypeError unless the ActiveSupport method #present returns true
  # for the receiver.
  # 
  def aT_present what_is_receiver=nil
    r = what_is_receiver ? what_is_receiver.to_s.capitalize :
      "#{self.class} instance #{object_id}"
    m = "#{r} fails to be #present?!"
    raise TErr, m unless present?
    return self
  end

  private

  def singleton_class_or_class
    begin
      self.singleton_class
    rescue TypeError
      self.class
    end
  end
end
