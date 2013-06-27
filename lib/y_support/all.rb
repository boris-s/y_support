#encoding: utf-8

require 'y_support'
require 'y_support/name_magic'
require 'y_support/typing'
require 'y_support/unicode'
require 'y_support/respond_to'
require 'y_support/null_object'
require 'y_support/inert_recorder'
require 'y_support/local_object'
require 'y_support/try'
require 'y_support/abstract_algebra'
require 'y_support/kde'
require 'y_support/x'
require 'y_support/misc'


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
