# coding: utf-8

# This module contains methods with which FlexProxy and modules which include
# it are to be extended.
# 
module FlexCoerce::ModuleMethods
  # This method customizes the host class in which FlexCoerce is included
  # by setting up a parametrized subclass of FlexCoerce::FlexProxy and
  # extending the host class with FlexCoerce::ClassMethods.
  # 
  def customize_class host_class
    host_class.instance_exec do
      # Set up a parametrized subclass of FlexCoerce::FlexProxy
      param_class!( { FlexProxy: FlexCoerce::FlexProxy },
                    with: { host_class: host_class } )
    end
    host_class.extend FlexCoerce::ClassMethods
  end

  # This method customizes a module in which FlexCoerce is included by extending
  # it with FlexCoerce::ModuleMethods.
  # 
  def customize_module host_module
    host_module.extend FlexCoerce::ModuleMethods
  end

  # Hook method which is invoked whenever a module is included in another module
  # (or class, which is also a module).
  # 
  def included receiver
    if receiver.is_a? Class then # we have reached the host class
      customize_class( receiver )
    else # receiver is a Module
      customize_module( receiver )
    end
  end
end
