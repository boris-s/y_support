#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'
require 'minitest/spec'
require 'minitest/autorun'
# require './../lib/y_support/all'
require './../lib/y_support/typing'

class TypingTest < Test::Unit::TestCase
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
      assert @p.class_complies?( @p.class )
      assert ! @p.class_complies?( @k.class )
      @p.declare_class_compliance! @k.class
      assert @p.class_declares_compliance?( @k.class )
      assert_equal [ @k.class ], @p.declared_class_compliance
      assert_equal [], @k.declared_class_compliance
      assert @p.class_complies? Object
      o = Object.new
      assert_equal false, o.class_complies?( @l )
      o.extend @l
      assert_equal true, o.class_complies?( @l )
    end
  end

  context "general" do
    should "have AErr alias for ArgumentError" do
      assert_equal ::ArgumentError, ::AErr
    end
    
    should "have #aE raising ArgumentError if block falsey" do
      assert_raise AErr do 0.aE "yada yada" do self == 1 end end
      assert_nothing_raised do 0.aE "yada yada" do self == 0 end end
      assert_equal( "hello", "hello".aE( "have 4 unique letters" ) do
                      each_char.map{|e| e }.uniq.join.size == 4 end )
      assert_nothing_raised do 2.aE &:even? end
      assert_raise AErr do 3.aE &:even? end
      assert_raise AErr do nil.aE end
    end
    
    should "have #aE_not raising ArgumentError if block truey" do
      assert_raise AErr do 0.aE_not { self < 1 } end
      assert_nothing_raised do 1.aE_not { self == 2 } end
      assert_equal( "hello", "hello".aE_not( "have x" ) { include? 'x' } )
      assert_nothing_raised do 3.aE_not &:even? end
      assert_raise AErr do 2.aE_not &:even? end
      assert_raise AErr do "".aE_not end
      assert_raise AErr do "".aE_not end # noting #aE_not alias
    end
    
    should "have #tE_kind_of, alias #tE_is_a TErr enforcers" do
      assert_raise TErr do :o.tE_kind_of Numeric end
      assert_nothing_raised do 0.tE_kind_of Numeric end
      assert_equal( "hello", "hello".tE_kind_of( String ) )
      assert_raise TErr do :o.tE_is_a Numeric end
      assert_nothing_raised do 0.tE_is_a Numeric end
      assert_equal( "hello", "hello".tE_is_a( String ) )
    end
    
    should "have #aE_class_compliance, alias #aE_∈ enforcer" do
      Koko = Class.new; Pipi = Class.new
      koko = Koko.new; pipi = Pipi.new
      pipi.∈! koko.class.name.to_sym
      assert_raise AErr do koko.aE_∈ pipi.class.name.to_sym end
      assert_nothing_raised do koko.aE_∈ koko.class.name.to_sym end
      assert_nothing_raised do pipi.aE_∈ pipi.class.name.to_sym end
      assert_nothing_raised do pipi.aE_∈ koko.class.name.to_sym end
      assert_raise AErr do koko.aE_∈ Pipi end
      assert_nothing_raised do pipi.aE_∈ Pipi end
      assert_nothing_raised do pipi.aE_∈ Koko end
      assert_equal koko, koko.aE_∈( Koko )
      # passing mention of the alias
      assert_equal koko, koko.aE_ɱ_compliance( Koko )
    end
    
    should "have #aE_respond_to enforces" do
      assert_raise AErr do :o.aE_respond_to :each end
      assert_nothing_raised do {}.aE_respond_to :each end
      assert_equal( [:hello], [:hello].aE_respond_to( :each ) )
    end
    
    should "have #aE_equal, alias #aE= enforcer" do
      assert_raise AErr do 0.aE_equal 1 end
      assert_nothing_raised do 1.aE_equal 2.0/2.0 end
      assert_equal( "hello", "hello".aE_equal( " hello ".strip ) )
    end
    
    should "have #aE_not_equal enforcer" do
      assert_raise AErr do 1.aE_not_equal 1.0 end
      assert_nothing_raised do 7.aE_not_equal 42 end
      assert_equal( "hello", "hello".aE_not_equal( "goodbye" ) )
    end
    
    should "have #aE_blank enforcer" do
      assert_raise AErr do "x".aE_blank end
      assert_nothing_raised do ["", []].each{|e| e.aE_blank } end
      assert_equal( {}, {}.aE_blank )
    end
    
    should "have #aE_not_blank enforcer" do
      assert_raise AErr do nil.aE_not_blank end
      assert_nothing_raised do 0.aE_not_blank end
      assert_equal( "hello", "hello".aE_not_blank )
    end
    
    should "have #aE_present enforcer" do
      assert_raise AErr do nil.aE_present end
      assert_nothing_raised do 0.aE_present end
      assert_equal( "hello", "hello".aE_present )
    end
    
    should "have #aE_has_attr_reader enforcer" do
      assert_raise AErr do
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
      assert_raise AErr do [1, 2, 7].aE_all{|e| e < 5 } end
      assert_nothing_raised do [1, 2, 4].aE_all{|e| e < 5 } end
    end

    should "have #aE_all_kind_of enforcer" do
      assert_raise AErr do [1.0, 2.0, :a].aE_all_kind_of Numeric end
      assert_nothing_raised do [1.0, 2.0, 3].aE_all_kind_of Numeric end
    end

    should "have #aE_all_declare_kind_of class compliance enforcer" do
      assert_raise AErr do [1.0, 2.0, :a].aE_all_declare_kind_of Numeric end
      assert_nothing_raised do [1.0, 2.0, 3].aE_all_declare_class Numeric end
    end

    should "have #aE_all_numeric enforcer" do
      assert_raise AErr do [:a].aE_all_numeric end
      assert_nothing_raised do [1, 2.0].aE_all_numeric end
    end
    
    should "have #aE_subset_of enforcer" do
      assert_raise AErr do [6].aE_subset_of [*0..5] end
      assert_nothing_raised do [1,2].aE_subset_of [*0..5] end
    end
  end # context Enumerable

  context "Array" do
    should "have #aE_has, alias #aE_include, #aE_∋ enforcer" do
      assert_respond_to [1, 2, 4], :aE_has
      assert_raise AErr do [1, 2, 4].aE_has 3 end
      assert_nothing_raised do [1, 2, 4].aE_has 4 end
      assert_equal [6, 7], [6, 7].aE_has( 6 )
      assert_respond_to [1, 2, 4], :aE_include
      assert_raise AErr do [1, 2, 4].aE_include 3 end
      assert_nothing_raised do [1, 2, 4].aE_include 4 end
      assert_equal [6, 7], [6, 7].aE_include( 6 )
      assert_respond_to [1, 2, 4], :aE_∋
      assert_raise AErr do [1, 2, 4].aE_∋ 3 end
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
      assert_raise AErr do a.merge_synonym_keys!( :a, :b ) end
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
      assert_raises AErr do a.may_have( :a, syn!: :b ) end
      assert_raises AErr do a.∋?( :a, syn!: :b ) end
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
      assert_raises AErr do a.aE_has :z end
      assert_nothing_raised do a.aE_has :infile end
      assert_nothing_raised do a.aE_has :csv_out_file end
      class TestClass; def initialize( args )
                         args.aE_has :infile
                         args.aE_has :csv_out_file
                         args.aE_has :k
                       end end
      assert_nothing_raised do TestClass.new a end
      assert_raises AErr do a.aE_has( :a, syn!: :b ) end
      assert_equal "a", a.aE_has( :infile )
      assert_equal "k", a.aE_has( :k, syn!: [:o, :t] )
      assert_equal "b", a.aE_has( :c, syn!: :csv_out_file )
      assert_equal( { infile: 'a', c: 'b', k: 'k' }, a )
      assert_raises AErr do a.aE_has(:c) {|val| val == 'c'} end
      assert_nothing_raised do a.aE_has(:c) {|val| val == 'b'} end
    end
  end # context Hash
end # class ScruplesTest
