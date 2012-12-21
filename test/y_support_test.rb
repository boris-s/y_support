#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'
require 'minitest/spec'
require 'minitest/autorun'
require 'y_support/all'

describe ::NameMagic do
  before do
    @ç = Class.new do include NameMagic end
    @reporter = Object.new
    @reporter.singleton_class.class_exec { attr_reader :report, :naming }
    @ç.new_instance_hook do |instance|
      @reporter.define_singleton_method :report do
        "New instance reported"
      end
    end
    @ç.naming_hook do |name, instance, old_name|
      @reporter.define_singleton_method :naming do
        "Name of the new instance was #{name}"
      end
      name
    end
  end
  
  it "should work" do
    @ç.must_respond_to :const_magic
    @ç.instances.must_be_empty
    @ç.nameless_instances.must_be_empty
    @reporter.report.must_equal nil
    @ç.new( name: "Boris" )
    @reporter.report.must_equal "New instance reported"
    @reporter.naming.must_equal "Name of the new instance was Boris"
    ufo = @ç.new
    @ç.nameless_instances.must_equal [ufo]
    UFO = @ç.new
    @reporter.report.must_equal "New instance reported"
    @reporter.naming.must_equal "Name of the new instance was Boris"
    UFO.name
    @reporter.naming.must_equal "Name of the new instance was UFO"
    Elaine = @ç.new
    Elaine.name.must_equal :Elaine
  end
end

class YSupportTest < Test::Unit::TestCase
  context "Object" do
    should "Object have const_set_if_not_defined" do
      ◉ = Object.new
      assert_raise NameError do ◉.ⓒ::KOKO end
      ◉.const_set_if_not_dϝ :KOKO, 42
      assert_nothing_raised do ◉.ⓒ::KOKO end
      assert_equal 42, ◉.ⓒ::KOKO
      ◉.const_set_if_not_dϝ :KOKO, 43
      assert_equal 42, ◉.ⓒ::KOKO
      ɱ = ( class LOFA012345; self end )
      assert_raise NameError do ɱ::KOKO end
      ɱ.const_set_if_not_dϝ :KOKO, 42
      assert_nothing_raised do ɱ::KOKO end
      assert_equal 42, ɱ::KOKO
      ɱ.const_set_if_not_dϝ :KOKO, 43
      assert_equal 42, ɱ::KOKO
    end
    
    should "Object have const_redef_without_warning" do
      ◉ = Object.new
      ◉.const_set_if_not_dϝ :KOKO, 42
      ◉.const_redϝ_wo_warning :KOKO, 43
      assert_equal 43, ◉.ⓒ::KOKO
      ɱ = ( module LOFA012346; self end )
      ɱ.const_set_if_not_dϝ :KOKO, 42
      ɱ.const_redϝ_wo_warning :KOKO, 43
      assert_equal 43, ɱ::KOKO
    end

    should "Object have #null_object? (alias #null?)" do
      assert_equal true, (class Koko < NullObject; self end).new.null_object?
      assert_equal true, (class Koko < NullObject; self end).new.null?
      assert_equal [false, false], [nil.null_object?, nil.null?]
      assert_equal true, NullObject.new( :koko ).null?( :koko )
      assert_equal false, NullObject.new( :koko ).null?( :pipi )
    end
    
    should "Object have #Maybe() constructor for something / NullObject" do
      assert_equal NullObject, Maybe(nil).class
      assert_equal 42, Maybe(42)
    end
    
    should "Object have #Null() constructor always returning NullObject" do
      assert_equal NullObject, Null().class
    end
    
    should "Object have InertRecorder" do
      assert_kind_of InertRecorder, (class Xx < InertRecorder; self end).new
    end
    
    should "Object have constructors #InertRecorder() and #L() (for LocalObject)" do
      assert_equal InertRecorder, InertRecorder().class
      assert_equal LocalObject, ℒ().class
    end

    should "have RespondTo() constructor" do
      assert_equal RespondTo, RespondTo(:inspect).class
    end
  end # context Object
  
  context "Module" do
    should "have working #attr_accessor_with_default" do
      class TestCl; attr_accessor_with_default :hello do "world" end end
      testç = TestCl.new
      assert_equal( "world", testç.hello )
      testç2 = TestCl.new
      testç2.hello
      testç2.hello = "receiver.jpg"
      assert_equal( "receiver.jpg", testç2.hello )
    end
    
    should "have working autoreq" do
      module TestModule
        autoreq :fixture_class,
          descending_path: '.', ascending_path_prefix: '.'
      end
      ç = TestModule::FixtureClass
      assert_equal( "world", ç.new.hello )
    end
  end # context Module

  context "Enumerable" do
    should "introduce #all_kind_of? collection qualifier" do
      assert_equal true, [ 1, 1.0 ].all_kind_of?( Numeric )
      assert_equal false, [ 1, [1.0] ].all_kind_of?( Numeric )
    end
    
    should "introduce #all_numeric? collection qualifier" do
      assert_equal true, [1, 1.0].all_numeric?
      assert_equal false, [:a, 1].all_numeric?
    end
    
    should "have #subset_of? collection qualifier" do
      assert_equal( true, [1,2].subset_of?( [1,2,3,4] ) )
      assert_equal( false, [1,2].subset_of?( [2,3] ) )
      assert_equal( true, [1,2].subset_of?( [1,2] ) )
      assert_equal( true, [1, 1.0].subset_of?( [1.0, 2.0] ) )
    end
  end # context Enumerable

  context "Array" do
    should "have #to_hash" do
      assert_equal( {a: :b, c: :d}, [[:a, :b],[:c, :d]].to_hash )
      assert_equal( {k: :kokot, p: :pica}, [[:k, :o, :kokot], [:p, :i, :pica]].to_hash(2) )
    end

    should "have #each_consecutive_pair iterator" do
      assert_kind_of Enumerator, [].each_consecutive_pair
      assert_kind_of Enumerator, [:a].each_consecutive_pair
      assert_kind_of Enumerator, [:a, :b].each_consecutive_pair
      assert_kind_of Enumerator, [:a, :b, :c].each_consecutive_pair
      assert_equal [], [].each_consecutive_pair.collect{|e| e }
      assert_equal [], [:a].each_consecutive_pair.collect{|e| e }
      assert_equal [[:a, :b]], [:a, :b].each_consecutive_pair.collect{|e| e }
      assert_equal [[:a, :b], [:b, :c]], [:a, :b, :c].each_consecutive_pair.collect{|e| e }
    end

    should "have #to_proc in style &[ function, *arguments ]" do
      assert_equal [2, 3], [1, 2].map( &[:+, 1] )
    end
  end # context Array

  context "Hash" do
    should "have #default! custom defaulter" do
      defaults = { a: 1, b: nil }
      test = {}
      result = test.default!( defaults )
      assert_equal defaults, result
      assert_equal result.object_id, test.object_id
      test = { a: 11, b: 22 }
      assert_equal( { a: 11, b: 22 }, test.default!( defaults ) )
      test = { a: 11, c: 22 }
      assert_equal( { a: 11, b: nil, c: 22 }, test.default!( defaults ) )
    end
    
    should "have #with_keys and #modify_keys" do
      assert_equal( {"a" => :b, "c" => :d}, {a: :b, c: :d}.with_keys( &:to_s ) )
      assert_equal( {"a1" => 1, "c2" => 2}, {a: 1, c: 2}.modify_keys { |k, v|
                      k.to_s + v.to_s } )
      assert_equal( {"a1" => 1, "c2" => 2}, {a: 1, c: 2}.modify_keys {|p|
                      p[0].to_s + p[1].to_s } )
      assert_equal( {2 => 1, 4 => 2}, {1 => 1, 2 => 2}.modify_keys { |k, v|
                      k + v } )
      assert_equal( {2 => 1, 4 => 2}, {1 => 1, 2 => 2}.modify_keys { |p|
                      p[0] + p[1] } )
    end
    
    should "have #with_values and #modify_values" do
      assert_equal( { a: "b", c: "d" }, {a: :b, c: :d}.with_values( &:to_s ) )
      assert_equal( {a: "ab", c: "cd"}, {a: :b, c: :d}.modify_values { |k, v|
                      k.to_s + v.to_s } )
      assert_equal( {a: "ab", c: "cd"}, {a: :b, c: :d}.modify_values { |p|
                      p[0].to_s + p[1].to_s } )
      hh = { a: 1, b: 2 }
      hh.with_values! &:to_s
      assert_equal ["1", "2"], hh.values
      hh.modify_values! &:join
      assert_equal ["a1", "b2"], hh.values
    end

    should "have #modify" do
      assert_equal( { ab: "ba", cd: "dc" },
                    { a: :b, c: :d }
                      .modify { |k, v| ["#{k}#{v}".to_sym, "#{v}#{k}"] } )
    end
    
    should "have #dot! meta patcher for dotted access to keys" do
      h = Hash.new.merge!(aaa: 1, taint: 2)
      assert_raise ArgumentError do h.dot! end
      assert_nothing_raised do h.dot!( overwrite_methods: true ) end
      assert_equal( {aaa: 1}, {aaa: 1}.dot! )
    end
  end # context Hash
  
  context "Special case objects" do
    should "NullObject exist and comply" do
      assert defined? NullObject
      assert_equal Class, NullObject.class
      n = NullObject.new
      assert_equal [[], "null", 0.0, 0], [n.to_a, n.to_s, n.to_f, n.to_i]
      assert_equal [false, true], [n.present?, n.empty?]
      assert_nothing_raised { NullObject.new.
        must_have_attr_reader( :recorded_messages ) }
      assert_respond_to NullObject.new, :arbitrary_message
      n = NullObject.new :x
      n.arbitrary_message( :a, :b ) { "hello" }
      assert_equal :x, n.null_object_type
      assert_equal [ :arbitrary_message, [:a, :b] ], n.recorded_messages[0][0..1]
      assert_equal "hello", n.recorded_messages[0][2].call
      assert_equal "NullObject kokotina", NullObject.new( :kokotina ).inspect
    end
    
    should "InertRecorder exist and comply" do
      assert defined? InertRecorder
      assert_equal Class, InertRecorder.class
      n = InertRecorder.new
      assert_equal [true, false], [n.present?, n.blank?]
      assert_nothing_raised { InertRecorder.new.
        must_have_attr_reader( :recorded_messages ).
        must_have_attr_reader( :init_args ) }
      assert_respond_to InertRecorder.new, :arbitrary_message
      n = InertRecorder.new :x, :y
      n.arbitrary_message( :a, :b ) { "hello" }
      assert_equal [:x, :y], n.init_args
      assert_equal [ :arbitrary_message, [:a, :b] ], n.recorded_messages[0][0..1]
      assert_equal "hello", n.recorded_messages[0][2].call
    end
    
    should "LocalObject exist and comply" do
      assert defined? LocalObject
      assert_equal Class, LocalObject.class
      n = ℒ( 'this msg' )
      assert_equal 'this msg', n.signature
      assert_equal 'this msg', n.σ
    end
  end # context Special case objects
  
  context "RespondTo" do
    should "work" do
      assert defined? RespondTo
      assert_respond_to RespondTo.new(:hello), :===
        assert RespondTo.new(:each_char) === "hell'o"
      assert !( RespondTo.new(:each_char) === Object.new )
      assert !( RespondTo.new(:azapat) === Object.new )
      assert case ?x; when RespondTo.new(:each_char) then 1 else false end
      assert ! case ?x; when RespondTo.new(:azapat) then 1 else false end
    end
  end # context RespondTo
  
  context "Matrix" do
    should "have exposed #[]= method" do
      assert_equal ::Matrix[[1, 0, 0], [0, 0, 0]],
                   ::Matrix.zero(2, 3).tap{ |m| m.[]=(0, 0, 1) }
    end

    should "have #pp method" do
      assert_respond_to Matrix[[1, 2], [3, 4]], :pretty_print
      assert_respond_to Matrix[[1, 2], [3, 4]], :pp
    end

    should "have #correspondence_matrix method" do
      assert_respond_to Matrix, :correspondence_matrix
      assert_equal Matrix[[1, 0, 0], [0, 1, 0]],
                   Matrix.correspondence_matrix( [:a, :b, :c], [:a, :b] )
      assert_equal Matrix.column_vector( [1, 2] ),
                   Matrix.correspondence_matrix( [:a, :b, :c], [:a, :b] ) *
                     Matrix.column_vector( [1, 2, 3] )
      assert_equal 2, Matrix.correspondence_matrix( [1, 2], [1] ).column_size
    end

    should "have #column_to_a & #row_to_a" do
      assert_equal [1, 2, 3], Matrix[[1], [2], [3]].column_to_a
      assert_equal [2, 3, 4], Matrix[[1, 2], [2, 3], [3, 4]].column_to_a( 1 )
      assert_equal nil, Matrix.empty( 5, 0 ).column_to_a
      assert_equal [1], Matrix[[1], [2], [3]].row_to_a
      assert_equal [3], Matrix[[1], [2], [3]].row_to_a( 2 )
    end

    should "have aliased #row_vector, #column_vector methods" do
      assert_equal Matrix.column_vector( [1, 2, 3] ),
                   Matrix.cv( [1, 2, 3] )
      assert_equal Matrix.row_vector( [1, 2, 3] ),
                   Matrix.rv( [1, 2, 3] )
    end

    should "have #join_bottom and #join_right" do
      assert_equal Matrix[[1, 2], [3, 4]],
                   Matrix[[1, 2]].join_bottom( Matrix[[3, 4]] )
      assert_equal Matrix[[1, 2, 3, 4]],
                   Matrix[[1, 2]].join_right( Matrix[[3, 4]] )
    end

    should "have aliased #row_size, #column_size methods" do
      assert_equal 3, Matrix.zero(3, 2).height
      assert_equal 3, Matrix.zero(3, 2).number_of_rows
      assert_equal 2, Matrix.zero(3, 2).width
      assert_equal 2, Matrix.zero(3, 2).number_of_columns
    end
  end # context Matrix
  
  context "String" do
    should "have #can_be_integer? returning the integer or false if not convertible" do
      assert_equal 33, "  33".can_be_integer?
      assert_equal 8, " 010 ".can_be_integer?
      assert_equal false, "garbage".can_be_integer?
    end
    
    should "have #can_be_float? returning the float or false if not convertible" do
      assert_equal 22.2, ' 2.22e1'.can_be_float?
      assert_equal 10, " 010 ".can_be_float?
      assert_equal false, "garbage".can_be_float?
    end
    
    should "have #default! defaulter" do
      assert_equal "default", "".default!("default")
      assert_equal "default", " ".default!(:default)
      assert_equal "default", " \n ".default!("default")
      assert_equal "kokot", "kokot".default!("default")
      a = ""
      assert_equal a.object_id, a.default!("tata").object_id
    end
    
    should "have #stripn upgrade of #strip, which also strips newlines" do
      assert_equal "test test", " \n test test \n\n  \n ".stripn
    end
    
    should "have #compact for joining indented lines (esp. heredocs)" do
      assert_equal "test test test", "test\n test\n\n   \n   test\n  ".compact
      funny_string = <<-FUNNY_STRING.compact
                        This
                          is
                            a funny string.
                        FUNNY_STRING
      assert_equal( 'This is a funny string.', funny_string )
    end
    
    should "be able #underscore_spaces" do
      assert_equal "te_st_test", "te st test".underscore_spaces
    end
    
    should "have #symbolize stripping, removing capitalization and diacritics " \
    'as if to make a suitable symbol material' do
      assert_equal "Yes_prisoner", " \nYes, prisoner!?.; \n \n".symbolize
    end
    
    should "have #to_normalized_sym chaining #symbolize and #to_sym" do
      assert_equal :Yes_prisoner,  " \nYes, prisoner!?.; \n \n".to_normalized_sym
    end
  end # context String

  context "Symbol" do
    should "have #default! defaulter going through String#default!" do
      assert_equal :default, "".to_sym.default!(:default)
      assert_equal :default, "".to_sym.default!("default")
      assert_equal :default, " ".to_sym.default!("default")
      assert_equal :default, " \n ".to_sym.default!("default")
      assert_equal :kokot, :kokot.default!("default")
    end
    
    should "have #to_normalized_sym alias #ßß" do
      assert_equal :Yes_prisoner, (:" \nYes, prisoner!?.; \n \n").ßß
      assert_equal :Yes, (:" \nYes, \n").to_normalized_sym
    end
    
    should "have ~@ method for ~:symbol style .respond_to?" \
    'matching in case statements' do
      assert_kind_of RespondTo, ~:hello
      assert RespondTo(:<<) === "testing"
      assert case ?x; when ~:each_char then 1 else false end
      assert !case ?x; when ~:azapat then 1 else false end
    end
  end # context Symbol
end # class YSupportTest

class ScruplesTest < Test::Unit::TestCase
  P = Class.new
  K = Class.new
  L = Module.new

  context "with some classes" do
    setup do
      @p = P.new
      @k = K.new
      @l = L
    end

    should "have working class compliance methods" do
      assert @p.declares_ɱ_compliance?( @p.class )
      assert @p.declares_ɱ_compliance?( @p.class.name )
      assert !@p.declares_ɱ_compliance?( @k.class )
      assert !@p.declares_ɱ_compliance?( @k.class.name )
      @p.declare_ɱ_compliance! @k.class.name.to_sym
      assert @p.declares_ɱ_compliance?( @k.class.name.to_sym )
      assert_equal [ @p.class.name, @k.class.name ], @p.ɱ_compliance
      assert_equal [ @k.class.name ], @k.ɱ_compliance
      assert @p.declares_ɱ_compliance? Object
      o = Object.new
      assert_equal false, o.E?( @l )
      o.extend @l
      assert_equal true, o.E?( @l )
    end
  end

  context "general" do
    should "have AE alias for ArgumentError" do
      assert_equal ::ArgumentError, ::AE
    end
    
    should "have #aE raising ArgumentError if block falsey" do
      assert_raise AE do 0.aE "yada yada" do self == 1 end end
      assert_nothing_raised do 0.aE "yada yada" do self == 0 end end
      assert_equal( "hello", "hello".aE( "have 4 unique letters" ) do
                      each_char.map{|e| e }.uniq.join.size == 4 end )
      assert_nothing_raised do 2.aE &:even? end
      assert_raise AE do 3.aE &:even? end
      assert_raise AE do nil.aE end
    end
    
    should "have #aE_not raising ArgumentError if block truey" do
      assert_raise AE do 0.aE_not { self < 1 } end
      assert_nothing_raised do 1.aE_not { self == 2 } end
      assert_equal( "hello", "hello".aE_not( "have x" ) { include? 'x' } )
      assert_nothing_raised do 3.aE_not &:even? end
      assert_raise AE do 2.aE_not &:even? end
      assert_raise AE do "".aE_not end
      assert_raise AE do "".aE_not end # noting #aE_not alias
    end
    
    should "have #aE_kind_of, alias #aE_is_a AE enforcers" do
      assert_raise AE do :o.aE_kind_of Numeric end
      assert_nothing_raised do 0.aE_kind_of Numeric end
      assert_equal( "hello", "hello".aE_kind_of( String ) )
      assert_raise AE do :o.aE_is_a Numeric end
      assert_nothing_raised do 0.aE_is_a Numeric end
      assert_equal( "hello", "hello".aE_is_a( String ) )
    end
    
    should "have #aE_class_compliance, alias #aE_∈ enforcer" do
      Koko = Class.new; Pipi = Class.new
      koko = Koko.new; pipi = Pipi.new
      pipi.∈! koko.class.name.to_sym
      assert_raise AE do koko.aE_∈ pipi.class.name.to_sym end
      assert_nothing_raised do koko.aE_∈ koko.class.name.to_sym end
      assert_nothing_raised do pipi.aE_∈ pipi.class.name.to_sym end
      assert_nothing_raised do pipi.aE_∈ koko.class.name.to_sym end
      assert_raise AE do koko.aE_∈ Pipi end
      assert_nothing_raised do pipi.aE_∈ Pipi end
      assert_nothing_raised do pipi.aE_∈ Koko end
      assert_equal koko, koko.aE_∈( Koko )
      # passing mention of the alias
      assert_equal koko, koko.aE_ɱ_compliance( Koko )
    end
    
    should "have #aE_respond_to enforces" do
      assert_raise AE do :o.aE_respond_to :each end
      assert_nothing_raised do {}.aE_respond_to :each end
      assert_equal( [:hello], [:hello].aE_respond_to( :each ) )
    end
    
    should "have #aE_equal, alias #aE= enforcer" do
      assert_raise AE do 0.aE_equal 1 end
      assert_nothing_raised do 1.aE_equal 2.0/2.0 end
      assert_equal( "hello", "hello".aE_equal( " hello ".strip ) )
    end
    
    should "have #aE_not_equal enforcer" do
      assert_raise AE do 1.aE_not_equal 1.0 end
      assert_nothing_raised do 7.aE_not_equal 42 end
      assert_equal( "hello", "hello".aE_not_equal( "goodbye" ) )
    end
    
    should "have #aE_blank enforcer" do
      assert_raise AE do "x".aE_blank end
      assert_nothing_raised do ["", []].each{|e| e.aE_blank } end
      assert_equal( {}, {}.aE_blank )
    end
    
    should "have #aE_not_blank enforcer" do
      assert_raise AE do nil.aE_not_blank end
      assert_nothing_raised do 0.aE_not_blank end
      assert_equal( "hello", "hello".aE_not_blank )
    end
    
    should "have #aE_present enforcer" do
      assert_raise AE do nil.aE_present end
      assert_nothing_raised do 0.aE_present end
      assert_equal( "hello", "hello".aE_present )
    end
    
    should "have #aE_has_attr_reader enforcer" do
      assert_raise AE do
        Object.new.aE_has_attr_reader :nonexisting_attribute end
      assert_nothing_raised do
        class XXX; attr_reader :someattr end
        x = XXX.new
        x.aE_has_attr_reader :someattr
      end
      x = XXX.new
      assert_equal( x, x.aE_has_attr_reader(:someattr) )
    end
  end # context Object
  
  context "Enumerable" do
    should "have #aE_all enforcer" do
      assert_raise AE do [1, 2, 7].aE_all{|e| e < 5 } end
      assert_nothing_raised do [1, 2, 4].aE_all{|e| e < 5 } end
    end

    should "have #aE_all_kind_of enforcer" do
      assert_raise AE do [1.0, 2.0, :a].aE_all_kind_of Numeric end
      assert_nothing_raised do [1.0, 2.0, 3].aE_all_kind_of Numeric end
    end

    should "have #aE_all_declare_kind_of class compliance enforcer" do
      assert_raise AE do [1.0, 2.0, :a].aE_all_declare_kind_of Numeric end
      assert_nothing_raised do [1.0, 2.0, 3].aE_all_declare_class Numeric end
    end

    should "have #aE_all_numeric enforcer" do
      assert_raise AE do [:a].aE_all_numeric end
      assert_nothing_raised do [1, 2.0].aE_all_numeric end
    end
    
    should "have #aE_subset_of enforcer" do
      assert_raise AE do [6].aE_subset_of [*0..5] end
      assert_nothing_raised do [1,2].aE_subset_of [*0..5] end
    end
  end # context Enumerable

  context "Array" do
    should "have #aE_has, alias #aE_include, #aE_∋ enforcer" do
      assert_respond_to [1, 2, 4], :aE_has
      assert_raise AE do [1, 2, 4].aE_has 3 end
      assert_nothing_raised do [1, 2, 4].aE_has 4 end
      assert_equal [6, 7], [6, 7].aE_has( 6 )
      assert_respond_to [1, 2, 4], :aE_include
      assert_raise AE do [1, 2, 4].aE_include 3 end
      assert_nothing_raised do [1, 2, 4].aE_include 4 end
      assert_equal [6, 7], [6, 7].aE_include( 6 )
      assert_respond_to [1, 2, 4], :aE_∋
      assert_raise AE do [1, 2, 4].aE_∋ 3 end
      assert_nothing_raised do [1, 2, 4].aE_∋ 4 end
      assert_equal [6, 7], [6, 7].aE_∋( 6 )
    end
  end # context Array

  context "Hash" do
    should "have #merge_synonym_keys! method" do
      a = { a: 'a', b: 'b', k: 'k', o: 'k', t: 'k' }
      old = a.dup
      assert_respond_to a, :merge_synonym_keys!
      assert_equal false, a.merge_synonym_keys!( :a, nil )
      assert_equal old, a
      assert_equal nil, a.merge_synonym_keys!( :z, nil )
      assert_equal old, a
      assert_equal true, a.merge_synonym_keys!( :k, :o, :t )
      assert_equal( { a: 'a', b: 'b', k: 'k' }, a )
      old = a.dup
      assert_raise AE do a.merge_synonym_keys!( :a, :b ) end
      assert_equal old, a
      assert_equal true, a.merge_synonym_keys!( :c, :b )
      assert_equal( { a: 'a', c: 'b', k: 'k' }, a )
    end
    
    should "have #may_have, alias #∋? synonym key merger" do
      a = { a: 'ano', b: 'bobo', k: 'kokot', o: 'kokot', t: 'kokot' }
      assert_respond_to a, :may_have
      assert_respond_to a, :∋?
      old = a.dup
      assert_nothing_raised do a.may_have :z end
      assert_nothing_raised do a.∋? :z end
      assert_raises AE do a.may_have( :a, syn!: :b ) end
      assert_raises AE do a.∋?( :a, syn!: :b ) end
      assert_equal false, a.has?( :z )
      assert_equal nil, a.may_have( :z )
      assert_equal false, a.∋?( :z )
      assert_equal true, a.has?( :a )
      assert_equal a[:a], a.may_have( :a )
      assert_equal true, a.∋?( :a )
      assert_equal old, a
      assert_equal 'kokot', a.may_have( :k, syn!: [:o, :t] )
      assert_equal true, a.∋?( :k, syn!: [:o, :t] )
      assert_equal 'bobo', a.may_have( :c, syn!: :b )
      assert_equal true, a.∋?( :c, syn!: :b )
      assert_equal( { a: 'ano', c: 'bobo', k: 'kokot' }, a )
    end
    
    should "have #aE_has, alias #aE_∋ synonymizing enforcer" do
      a = { infile: 'a', csv_out_file: 'b', k: 'k', o: 'k', t: 'k' }
      assert_respond_to a, :aE_has
      old = a.dup
      assert_raises AE do a.aE_has :z end
      assert_nothing_raised do a.aE_has :infile end
      assert_nothing_raised do a.aE_has :csv_out_file end
      class TestClass; def initialize( args )
                         args.aE_has :infile
                         args.aE_has :csv_out_file
                         args.aE_has :k
                       end end
      assert_nothing_raised do TestClass.new a end
      assert_raises AE do a.aE_has( :a, syn!: :b ) end
      assert_equal "a", a.aE_has( :infile )
      assert_equal "k", a.aE_has( :k, syn!: [:o, :t] )
      assert_equal "b", a.aE_has( :c, syn!: :csv_out_file )
      assert_equal( { infile: 'a', c: 'b', k: 'k' }, a )
      assert_raises AE do a.aE_has(:c) {|val| val == 'c'} end
      assert_nothing_raised do a.aE_has(:c) {|val| val == 'b'} end
    end
  end # context Hash
end # class ScruplesTest
