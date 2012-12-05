#encoding: utf-8
require "y_support/version"

require 'mathn'
require 'set'
require 'csv'
require 'matrix'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/duplicable'
require 'active_support/core_ext/string/starts_ends_with'
require 'active_support/core_ext/string/strip'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/integer/multiple'
require 'active_support/core_ext/integer/inflections'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/conversions' # such as #to_xml
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/diff'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/hash/indifferent_access'

require 'y_unicode'
require 'y_scruples'

include YUnicode
include YScruples

module YSupport
  def self.included( receiver )
    ::Object.module_exec {
      def const_set_if_not_defined( const, value )
        mod = self.is_a?(Module) ? self : self.singleton_class
        mod.const_set( const, value ) unless mod.const_defined?( const )
      end
      alias :const_set_if_not_dϝ :const_set_if_not_defined
      
      def const_redef_without_warning( const, value )
        mod = self.is_a?(Module) ? self : self.singleton_class
        mod.send(:remove_const, const) if mod.const_defined?( const )
        mod.const_set( const, value )
      end
      alias :const_redϝ_wo_warning :const_redef_without_warning
      
      def null_object?( what = nil )
        is_a?( NullObject ) and  what.nil? ? true : self.what == what
      end
      alias :null? :null_object?
      
      # Converts #nil?-positive objects to NullObjects. If 2 arguments
      # are given, then first is considered what object type descriptor,
      # and second object to judge.
      def Maybe(a1, a2 = ℒ)
        if a2.ℓ? then value = a1 else what, value = a1, a2 end
        if value.nil? then NullObject.new what else value end
      end
      
      # NullObject constructor
      def Null( what=nil ); NullObject.new what end
      
      # InertRecorder constructor
      def InertRecorder *aj, &b; InertRecorder.new *aj, &b end
      
      # LocalObject constructor
      def LocalObject signature = nil; LocalObject.new signature end
      alias :ℒ :LocalObject
      
      # #local_object? inquirer
      def local_object? s = nil; is_a? LocalObject and signature == s end
      alias :ℓ? :local_object?

      # RespondTo constructor
      def RespondTo method; RespondTo.create method end
      
      # Create public attributes (ie. with readers) and initialize them with
      # prescribed values. Takes a hash of { symbol => value } pairs. Existing methods
      # are not overwritten by the new getters, unless option :overwrite_methods
      # is set to true.
      def singleton_set_attr_with_readers( hash, oo = {} )
        hash.each { |key, val|
          key = key.aE_respond_to( :to_sym, "key of the attr hash" ).to_sym
          instance_variable_set( "@#{key}", val )
          if oo[:overwrite_methods] then ⓒ.module_exec { attr_reader key }
          elsif methods.include? key
            raise "Attempt to add \##{key} getter failed: " +
              "method \##{key} already defined."
          else ⓒ.module_exec { attr_reader key } end
        }
      end
      alias :ⓒ_set_attr_w_readers :singleton_set_attr_with_readers
    } # Object.module_exec

    ::Module.module_exec do
      def autoreq( *ßs )
        options = ßs.extract_options!
        this_ɴspace = self.name
        this_ɴspace_path = this_ɴspace.underscore
        ɴspace_chain = this_ɴspace.split "::"
        options.default!( descending_path: '..', ascending_path_prefix: 'lib' )
        descending_path = options[:descending_path]
        ascending_path_prefix = options[:ascending_path_prefix]
        ascending_path = ascending_path_prefix + '/' + this_ɴspace_path
        ßs.each { |ß|
          str = ß.to_s.stripn; next if str.blank?
          camelized_ß = str.camelize.to_sym
          path = './' + [ descending_path, ascending_path, str ].join( '/' )
          autoload camelized_ß, path }
      end
      
      # I didn't write this method by myself
      def attr_accessor_withe_default *symbols, &block
        raise 'Default value in block required' unless block
        symbols.each { |ß|
          module_eval {
            attr_writer ß
            define_method ß do
              class << self; self end.module_eval { attr_reader(ß) }
              if instance_variables.include? "@#{ß}" then 
                instance_variable_get "@#{ß}"
              else
                instance_variable_set "@#{ß}", block.call
              end
            end
          }
        }
      end
    end # Module.module_exec
    
    ::Enumerable.module_exec do
      # Checks whether #all? are #kind_of? the ç provided as argument
      def all_kind_of?( ç ); all? {|e| e.kind_of? ç } end
      
      # Checks whether #all? are #kind_of? ::Numeric.
      def all_numeric?; all? {|e| e.kind_of? Numeric } end
      
      # Checks whether receiver is a "subset" of the argument
      def subset_of?( other ); all? {|e| other.include? e } end
      alias :⊂? :subset_of?
      
      # Checks whether the argument is a "subset" of the receiver
      def superset_of?( other ); other.all? {|e| self.include? e } end
      alias :⊃? :superset_of?
    end # Enumerable.module_exec
    
    ::Array.module_exec do
      # Converts an array, whose elements are also arrays, to a hash.  Head
      # (position 0) of each array is made to point at the rest of the array
      # (tail), normally starting immediately after the head (position 1). The
      # starting position of the tail can be controlled by an optional
      # argument. Tails of 2 and more elements are represented as arrays.
      def to_hash( tail_from = 1 )
        self.reject { | e | e[0].nil? }.reduce({}) { |a, e|
          tail = e[tail_from..-1]
          a.merge( { e[0] => tail.size >= 2 ? tail : tail[0] } )
        }
      end

      # Does things for each consecutive pair (expects a binary block).
      def each_consecutive_pair
        if block_given?
          return self if ( n = self.size - 1 ) <= 0
          n.times.with_index{|i| yield( self[i], self[i+1] ) }
          return self
        else
          return Enumerator.new do |yielder|
            n.times.with_index{|i| yielder << [ self[i], self[i+1] ] } unless
              ( n = self.size - 1 ) <= 0
          end
        end
      end

      # Allows style &[ function, *arguments ]
      def to_proc
        proc { |receiver| receiver.send *self }
      end # def to_proc

      # TEST ME
      # def pretty_inspect
      #   each_slice( 4 ) { |slice|
      #     slice.map { |e|
      #       str = e.to_s[0..25]
      #       str + ' ' * ( 30 - str.size )
      #     }.reduce( :+ ) + "\n"
      #   }.reduce( :+ )
      # end
    end # Array.module_exec
    
    # and include self
    ::Hash.module_exec do
      # reversed merge!: defaults.merge( self! )
      alias :default! :reverse_merge!
      
      # Applies a block as a mapping on all keys, returning a new hash
      def with_keys
        keys.each_with_object ç.new do |key, ꜧ|
          ꜧ[yield k] = self[k]
        end
      end
      alias :do_with_keys :with_keys
      
      # The difference from do_with_keys is that modify_keys expects block
      # that takes 2 arguments (key: value pair) and returns the new key.
      def modify_keys
        each_with_object ç.new do |pair, ꜧ|
          ꜧ[yield pair] = self[pair[0]]
        end
      end
      
      # Applies a block as a mapping on all values, returning a new hash
      def with_values
        each_with_object ç.new do |pair, ꜧ|
          ꜧ[pair[0]] = yield pair[1]
        end
      end
      alias :do_with_values :with_values
      
      # Like #do_with_values, but modifies the receiver.
      def with_values!
        each_with_object self do |pair, ꜧ|
          ꜧ[pair[0]] = yield pair[1]
        end
      end
      alias :do_with_values! :with_values!
      
      # The difference from #do_with_values is that modify_values expects block
      # that takes 2 arguments (key: value pair) and returns the new value.
      def modify_values
        each_with_object ç.new do |pair, ꜧ|
          ꜧ[pair[0]] = yield pair
        end
      end
      
      # Like #modify_values, but modifies the receiver
      def modify_values!
        each_with_object self do |pair, ꜧ|
          ꜧ[pair[0]] = yield pair
        end
      end

      # Like #map that returns a hash.
      def modify
        each_with_object ç.new do |pair, ꜧ|
          key, val = yield pair
          ꜧ[key] = val
        end
      end
      
      # Makes ꜧ keyj accessible as mτj. If the hash keys collide with its
      # methods, ArgumentError is raised, unless :overwrite_mτs option == true.
      def dot!( oo = {} )
        keys.each { |key|
          msg = "key #{key} of #dot!-ted ꜧ is not convertible to a ß"
          raise ArgumentError, msg unless key.respond_to? :to_ß
          unless oo[:overwrite_mτs]
            if methods.include? key.to_ß
              raise ArgumentError, "#dot!-ted ꜧ must not have key ɴs colliding w its mτs"
            end
          end
          dϝ_ⓒ_mτ key.to_ß do self[key] end
          dϝ_ⓒ_mτ "#{key}=".to_ß do |value| self[key] = value end
        }
        return self
      end
    end # Hash.module_exec
    
    ::String.module_exec {
      # Integer() style conversion, or false if conversion impossible.
      def can_be_integer?
        begin; int = Integer( self.stripn ); return int
        rescue AE; return false end
      end
      
      # Float() style conversion, or false if conversion impossible.
      def can_be_float?
        begin; fl = Float( self.stripn ); return fl
        rescue AE; return false end
      end
      
      # #stripn is like #strip, but also strips newlines
      def stripn; encode(universal_newline: true).gsub("\n", "").strip end
      
      # Joins a paragraph of possibly indented, newline separated lines into a
      # single contiguous string.
      def compact
        encode(universal_newline: true).split("\n"). # split into lines
          map( &:strip ).delete_if( &:blank? ).join " " # strip and join lines
      end
      
      # #default replaces an empty string (#empty?) with provided default
      # string.
      def default! default_string
        strip.empty? ? clear << default_string.to_s : self
      end
      
      # underscores spaces
      def underscore_spaces; gsub( ' ', '_' ) end
      
      # Strips a ς (#stripn), removes criminal chars & underscores spaces
      def symbolize
        x = self; ",.?!;".each_char{|c| x.gsub!(c, " ")}
        return x.stripn.squeeze(" ").underscore_spaces
      end
      alias :ßize :symbolize
      
      # chains #symbolize and #to_sym
      def to_normalized_sym; symbolize.to_sym end
      alias :ßß :to_normalized_sym
    } # String.module_exec
    
    Symbol.module_exec {
      # Symbol's method #dℲ! just applies String's #dℲ! to a Symbol. Of
      # course, a symbol cannot change, so despite the exclamation mark, new
      # symbol is returned whenever the original is considered "defaulted".
      # Ordinary #default does not work with symbols, as symbols are never
      # considered blank.
      def default!( default_value )
        to_s.default!( default_value ).to_sym
      end
      
      # Chains #symbolize and #to_sym
      def to_normalized_sym; to_s.to_normalized_sym end
      alias :ßß :to_normalized_sym
      
      # Creates a RespondTo object from self. (Usef for ~:symbol style matching
      # in case statements)
      def ~@; RespondTo self end
    }
    
    ::Matrix.module_exec {
      # exposing the #[]= modificator method
      alias :private_element_assignment :[]=
      def []=( a, b, newval )
        private_element_assignment a, b, newval
      end

      # Pretty inspect
      def pretty_inspect
        return inspect if row_size == 0 or column_size == 0
        aa = send(:rows).each.with_object [] do |row, memo|
          memo << row.map{ |o|
            os = o.to_s
            case o
            when Numeric then os[0] == '-' ? os : ' ' + os
            else o.to_s end
          }
        end
        width = aa.map{ |row| row.map( &:size ).max }.max + 1
        aa.each_with_object "" do |row, memo|
          row.each{ |e| memo << e << ' ' * ( width - e.size ) }
          memo << "\n"
        end
      end

      # Pretty print
      def pretty_print
        print pretty_inspect
        return nil
      end
      alias :pp :pretty_print

      # Given two arrays, creates correspondence matrix, with no. of cols
      # equal to the 1st array, and no. of rows to the 2nd. This matrix can
      # be used eg. for conversion between column vectors corresponding to
      # the 1st and 2nd array:
      #
      # Matrix.correspondence_matrix( array1, array2 ) * col_vector_1
      # #=> col_vector_2
      # 
      def self.correspondence_matrix( array1, array2 )
        return Matrix.empty 0, array1.size if array2.empty?
        return Matrix.empty array2.size, 0 if array1.empty?
        self[ *array2.map { |e2| array1.map { |e1| e1 == e2 ? 1 : 0 } } ]
      end

      # Converts a column into array. If argument is given, it chooses
      # column number, otherwise column 0 is assumed.
      def column_to_a n=0; ( col = column( n ) ) ? col.to_a : nil end

      # Converts a row into array. If argument is given, it chooses row
      # number, otherwise row 0 is assumed.
      def row_to_a n=0; ( r = row( n ) ) ? r.to_a : nil end

      # Shorter aliases for #row_vector, #column_vector
      def self.cv *aa, &b; column_vector *aa, &b end
      def self.rv *aa, &b; row_vector *aa, &b end

      # #join_bottom method
      def join_bottom other;
        raise ArgumentError, "Column size mismatch" unless
          column_size == other.column_size
        return other.map &:ɪ if row_size == 0
        return Matrix.empty row_size + other.row_size, 0 if column_size == 0
        ç[ *( row_vectors + other.row_vectors ) ]
      end

      #join_right methods
      def join_right other;
        raise ArgumentError, "Row size mismatch" unless
          row_size == other.row_size
        ( t.join_bottom( other.t ) ).t
      end

      # aliasing #row_size, #column_size
      alias :number_of_rows :row_size
      alias :number_of_columns :column_size
      alias :height :number_of_rows
      alias :width :number_of_columns
    } # Matrix.instance_exec
    
    ::Vector.instance_exec {
      # .zero class method returns a vector filled with zeros
      def zero( vector_size ); self[*([0] * vector_size)] end
    } # Vector.instance_exec
  end # def self.included
  
  # Special case pattern: NullObject class
  class NullObject
    attr_reader :what, :recorded_msgj
    alias :ρ :recorded_msgj
    def initialize( what = nil ); @what, @recorded_msgj = what, [] end
    def to_a; []; end
    def to_s; "null #{what}".strip; end
    def to_f; 0.0; end
    def to_i; 0; end
    def present?; false end
    def empty?; true end
    def blank?; true end
    def inspect; "NullObject #{what}".strip end
    def method_missing ß, *aj, &b; @recorded_msgj << [ ß, aj, b ]; self end
    def respond_to? ß, *aj, &b; true end
  end
    
  # InertRecorder class
  class InertRecorder
    attr_reader :init_argj, :recorded_msgj
    alias :ρ :recorded_msgj
    
    def initialize *aj, &b
      @init_argj, @init_block, @recorded_msgj = aj, b, []
    end
    
    def method_missing ß, *aj, &b; @recorded_msgj << [ ß, aj, b ]; self end
    def respond_to? ß, *aj, &b; true end
    alias :ʀ? :respond_to?
    def present?; true end
    def blank?; false end
  end # class InertRecorder
  
  # Object that should stay local to methods.
  class LocalObject
    attr_reader :signature
    alias :σ :signature
    def initialize sgn = nil; @signature = sgn end
  end
  
  # RespondTo class for easy use of respond_to? in case statements
  class RespondTo
    Matchers = {}
    attr_reader :method
    def self.create method; Matchers[method] ||= new method end
    def initialize method; @method = method end
    def === obj; obj.respond_to? method end
  end

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
end
