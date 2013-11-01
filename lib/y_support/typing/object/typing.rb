#encoding: utf-8

require 'active_support/core_ext/object/blank'
require 'y_support/core_ext/object/inspection'
require 'y_support/core_ext/string/misc'

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
  def aT what_is_receiver=insp, how_comply=nil, &b
    if block_given? then
      if b.( self ) then self else
        m = "%s fails " + ( how_comply ? "to #{how_comply}" : "its check" )
        fail TypeError, m.X!( what_is_receiver ) 
      end
    else self or fail TypeError end
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
  def aT_not what_is_receiver=insp, how_comply=nil, &b
    tap do
      if block_given? then
        if b.( self ) then
          m = how_comply ? "%s must not #{how_comply}" : "%s fails its check"
          fail TypeError, m.X!( what_is_receiver )
        end
      else fail TypeError if self end
    end
  end

  # Fails with TypeError unless the receiver is of the prescribed class. Second
  # optional argument customizes the error message (receiver description).
  # 
  def aT_kind_of klass, what_is_receiver=insp
    tap do
      is_a? klass or fail TypeError, "%s not a #{klass}".X!( what_is_receiver )
    end
  end
  alias aT_is_a aT_kind_of

  # Fails with TypeError unless the receiver declares compliance with the
  # given class, or is a descendant of that class. Second optional argument
  # customizes the error message (receiver description).
  # 
  def aT_class_complies klass, what_is_receiver=insp
    if class_complies? klass then
      fail TypeError, "%s does not comply with #{klass}".X!( what_is_receiver )
    else self end
  end
  
  # Fails with TypeError unless the receiver responds to the given
  # method. Second optional argument customizes the error message (receiver
  # description).
  # 
  def aT_respond_to method_name, what_is_receiver=insp
    if respond_to? method_name then self else
      m = "%s does not respond to method '#{method_name}'"
      fail TypeError, m.X!( what_is_receiver )
    end
  end
  alias aT_responds_to aT_respond_to
  
  # Fails with TypeError unless the receiver, according to #== method, is
  # equal to the argument. Two more optional arguments customize the error
  # message (receiver description and the description of the other object).
  # 
  def aT_equal other, what_is_receiver=insp, what_is_other=nil
    if self == other then self else
      wo = what_is_other || "the prescribed value (#{other.insp})"
      fail TypeError, "%s must be equal to %s".X!( [ what_is_receiver, wo ] )
    end
  end

  # Fails with TypeError unless the receiver, according to #== method, differs
  # from to the argument. Two more optional arguments customize the error
  # message (receiver description and the description of the other object).
  # 
  def aT_not_equal other, what_is_receiver=insp, what_is_other=nil
    if self == other
      wo = what_is_other || "the prescribed value (#{other.insp})"
      fail TypeError, "%s must not == %s".X!( [ what_is_receiver, wo ] )
    else self end
  end

  # Fails with TypeError unless the ActiveSupport method #blank returns true
  # for the receiver.
  # 
  def aT_blank what_is_receiver=insp
    tap { blank? or fail TypeError, "%s not blank".X!( what_is_receiver ) }
  end

  # Fails with TypeError unless the ActiveSupport method #present returns true
  # for the receiver.
  # 
  def aT_present what_is_receiver=insp
    tap { present? or fail TypeError, "%s not present".X!( what_is_receiver ) }
  end

  private

  # Some objects do not have accessible singleton class. This method returns
  # the singleton class for those object, which have a singleton class, and
  # self.class for others.
  # 
  def singleton_class_or_class
    begin; self.singleton_class; rescue TypeError; self.class end
  end
end
