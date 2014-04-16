# encoding: utf-8

require 'y_support'

# Typing library.
#
# Apart from typing objects <em>by class and ancestry</em> (+#kind_of?+),
# y_support typing library provides support for typing <em>by declaration</em>,
# and for runtime assertions.

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
