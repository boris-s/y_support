#encoding: utf-8

require 'y_support'

# Typing library.
#
# Apart from Ruby default way of typing objects <em>by class and ancestry</em>,
# exemplified eg. by built-in #kind_of?, alias #is_a? inquirers, y_support
# typing library provides support for typing <em>by declaration</em>, and
# runtime assertions for <em>duck type</em> examination.
# 
# 1. Using method <b>declare_compliance</b>, a module (class) can explicitly
# declare, that it provides an interface compliant with another module (class).
# Corresponding inquirer methods are <b>declared_compliance</b> (returns a list
# of modules, to which the receiver declares compliance, or implicitly complies
# by ancestry), and <b>declares_compliance?( other_module )</b>, which tells,
# whether the receiver complies with a specific module. An object always
# implicitly complies with its class and ancestry.
# 
# 2. Duck type examination is supported by a collection of runtime assertions.
# These start with <b>tE_...</b>, meaning "enforce ... by raising TypeError".
# 
class Object
  # Alias for ArgumentError
  # 
  AErr = ArgumentError
  
  # Alias for TypeError
  # 
  TErr = TypeError
end

directories_to_look_in = [ :typing ]

# The fololowing code looks into the specified directory(ies) and requires
# all the files in it (them).
# 
directories_to_look_in.each do |part|
  Dir["#{File.dirname( __FILE__ )}/#{part}/*/typing.rb"].sort.each { |path|
    dir = File.dirname( path ).match( "y_support/#{part}" ).post_match
    require "y_support/#{part}#{dir}/typing"
  }
end
