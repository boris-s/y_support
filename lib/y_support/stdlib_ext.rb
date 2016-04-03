Dir["#{File.dirname( __FILE__ )}/stdlib_ext/*.rb"].sort.each do |path|
  require_relative "y_support/stdlib_ext/#{File.basename( path, '.rb' )}"
end

