#encoding: utf-8
require 'y_support'

# Typing library.
#
# Apart from usual <em>typing by class and ancestry</em>, supported by built-in
# #kind_of?, alias #is_a? inquirerers, this typing library provides support for
# provides support for <em>typing by declaration</em> and <em>duck typing</em>.
# 
# 1. Using method <b>declare_compliance</b>, a module can explicitly declare that
# it provides the interface compliant with another module. Corresponding inquirer
# methods are <b>declared_compliance</b> (returning a list of modules with which
# the receiver declares compliance or implicitly complies) and
# <b>declares_compliance?( other_module )</b>, which anwers whether the receiver
# complies with other_module. An object always implicitly complies with its class
# and class ancestry.
# 
# 2. Duck type enforcement for method parameters is supported by a collection of
# enforcer methods (aka. run-time assertions). These methods look very much like
# assertions, but they start with <b>tE_...</b>, meaning "enforce by raising
# TypeError".

class Object
  # Alias for ArgumentError
  # 
  AErr = ArgumentError
  
  # Alias for TypeError
  # 
  TErr = TypeError
end

[ :core_ext, :stdlib_ext ].each do |ext|
  Dir["#{File.dirname( __FILE__ )}/#{ext}/*/misc.rb"].sort.each { |path|
    dir = File.dirname( path ).match( "y_support/#{ext}" ).post_match
    require "y_support/#{ext}#{dir}/misc"
  }
end
