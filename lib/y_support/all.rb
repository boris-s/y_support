# -*- coding: utf-8 -*-
require 'y_support'
require 'y_support/name_magic'
require 'y_support/unicode'
require 'y_support/respond_to'
require 'y_support/null_object'
require 'y_support/local_object'
puts require 'y_support/core_ext'
require 'y_support/stdlib_ext'

# *** DEVELOPMENT REMARKS FOLLOW ***

# Typing library.
#
# 1. Standard way of object typing is TYPING BY CLASS AND CLASS ANCESTRY.
# 2. More powerful TYPING BY DECLARATION is supported by method
# <b>declare_module_compliance</b>, by which it is declared that one module
# provides the same interface as another module. Inquirer methods are
# <b>module_compliance</b> (returns a list of modules with which the receive
# complies) and <b>declares_module_compliance?</b>, which anwers whether the
# receiver complies with a particular module. An object always implicitly
# complies with its class and class ancestry.
# 3. DUCK TYPING. Duck type enforcement for method parameters is supported
# by a collection of enforcer methods. These methods look very much like
# assertions, but they start with <b>aE_...</b>, meaning "enforce by raising
# argument error".
#
# The library name comes from the scruple character <b>℈</b>, which can be
# used instead of capital <b>E</>, meaning error. The scruple character ℈
# (U+2108) originally meant a pharmaceutical unit, but here it is used more
# in its sense of "moral reservation" - towards the input arguments.
#
# All Scruples methods raise ArgumentError (aliased as AE/A℈) if the
# receiver fails the expectations. Those using Kragen's .XCompose file
# (https://github.com/kragen/xcompose) can type ℈ as compose, s, c, r, dot.









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
