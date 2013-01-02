# -*- coding: utf-8 -*-
require 'y_support'
require 'y_support/name_magic'
require 'y_support/typing'
require 'y_support/unicode'
require 'y_support/respond_to'
require 'y_support/null_object'
require 'y_support/local_object'
require 'y_support/core_ext'
require 'y_support/stdlib_ext'

# # Redefining constants without warnings, useful for mocking.
# def const_set_if_not_dϝ(const, value)
#   mod = self.is_a?(Module) ? self : self.singleton_class
#   mod.const_set(const, value) unless mod.const_defined?(const)
# end

# def const_redϝ_wo_warning(const, value)
#   mod = self.is_a?(Module) ? self : self.singleton_class
#   mod.send(:remove_const, const) if mod.const_defined?(const)
#   mod.const_set(const, value)
# end

# # Test me!
# class BlankSlate
#   class << self
#     # Hide the method named +name+ in the BlankSlate class. Don't
#     # hide +instance_eval+ or any method beginning with "__".
#     def hide( name )
#       if instance_methods.include? name and
#           name !~ /^(__|instance_eval)/
#         @hidden_methods ||= {}
#         @hidden_methods[name] = instance_method name
#         undef_method name
#       end
#     end

#     def find_hidden_method name
#       @hidden_methods ||= {}
#       @hidden_methods[name] || superclass.find_hidden_method( name )
#     end

#     # Redefine a previously hidden method
#     def reveal name
#       unbound_method = find_hidden_method name
#       fail "Don't know how to reveal method '#{name}'" unless unbound_method
#       define_method( name, unbound_method )
#     end
#   end
# end # class BlankSlate
