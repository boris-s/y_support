require 'y_support'

module YSupport::X
  class << self
    # Echo a string to the primary X clip with `xsel -b -i`.
    # 
    def echo_primary_clipboard( string )
      system 'echo -n "' + string + '" | xsel -b -i'
    end

    # Echo a string to the secondary X clip with `xsel -b -i`.
    # 
    def echo_secondary_clipboard( string )
      system 'echo -n "' + string + '" | xsel -s -i'
    end
  end
end # module YSupport::X
