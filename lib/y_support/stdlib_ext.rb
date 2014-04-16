Dir["#{File.dirname( __FILE__ )}/stdlib_ext/*.rb"].sort.each do |path|
  require "y_support/stdlib_ext/#{File.basename( path, '.rb' )}"
end

