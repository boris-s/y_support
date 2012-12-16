#encoding: utf-8
puts "hello"
puts "hello"
puts "hello"
Dir["#{File.dirname( __FILE__ )}/core_ext/*.rb"].sort.each do |path|
  puts "y_support/core_ext/#{File.basename( path, '.rb' )}"
  require "y_support/core_ext/#{File.basename( path, '.rb' )}"
end
