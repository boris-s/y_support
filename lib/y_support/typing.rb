# encoding: utf-8

require_relative '../y_support'

# Typing library.
#
# A collection of helper methods mainly for argument validation. We often want
# to validate that arguments are of certain class, or that they fulfill some
# other criteria, and raise sufficiently informative error messages when not.
# I've been also experimenting with what I call "typing by declaration", that
# is, when a class declares compliance with another class without actually
# being its descendant, but this idea is still experimental. Basically,
# 'y_support/typing' remains a library of runtime assertions.

directories_to_look_in = [ :typing ]

# The following code looks into the specified directory(ies) and requires
# all the files in it (them).
# 
directories_to_look_in.each do |name|
  Dir["#{File.dirname( __FILE__ )}/#{name}/*/typing.rb"].sort.each do |path|
    dir = File.dirname( path ).match( "y_support/#{name}" ).post_match
    require_relative "#{name}#{dir}/typing"
  end
end
