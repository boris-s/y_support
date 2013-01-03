#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'
require 'minitest/spec'
require 'minitest/autorun'
require 'y_support/typing'

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
      assert_raise TErr do 0.aT "yada yada" do self == 1 end end
      assert_nothing_raised do 0.aT "yada yada" do self == 0 end end
      assert_equal( "hello",
                    "hello".aT( "have 4 unique letters" ) {
                      each_char.map { |e| e }.uniq.join.size == 4
                    } )
      assert_nothing_raised do 2.aT &:even? end
      assert_raise TErr do 3.aT &:even? end
      assert_raise TErr do nil.aT end
    end
    
    should "have #aT_not raising TypeError if block truey" do
      assert_raise TErr do 0.aT_not { self < 1 } end
      assert_nothing_raised do 1.aT_not { self == 2 } end
      assert_equal( "hello", "hello".aT_not( "have x" ) { include? 'x' } )
      assert_nothing_raised do 3.aT_not &:even? end
      assert_raise TErr do 2.aT_not &:even? end
      assert_raise TErr do "".aT_not end
    end
    
    should "have #aT_kind_of, alias #aT_is_a TErr enforcers" do
      assert_raise TErr do :o.aT_kind_of Numeric end
      assert_nothing_raised do 0.aT_kind_of Numeric end
      assert_equal( "hello", "hello".aT_kind_of( String ) )
      assert_raise TErr do :o.aT_is_a Numeric end
      assert_nothing_raised do 0.aT_is_a Numeric end
      assert_equal( "hello", "hello".aT_is_a( String ) )
    end
    
    should "have #aT_complies" do
      Koko = Class.new; Pipi = Class.new
      koko = Koko.new; pipi = Pipi.new
      pipi.declare_class_compliance! koko.class
      assert_raise TErr do koko.aT_class_complies pipi.class end
      assert_nothing_raised do koko.aT_class_complies koko.class end
      assert_nothing_raised do pipi.aT_class_complies pipi.class end
      assert_nothing_raised do pipi.aT_class_complies koko.class end
      assert_raise TErr do koko.aT_class_complies Pipi end
      assert_nothing_raised do pipi.aT_class_complies Pipi end
      assert_nothing_raised do pipi.aT_class_complies Koko end
      assert_equal koko, koko.aT_class_complies( Koko )
    end
    
    should "have #aT_respond_to enforcer" do
      assert_raise TErr do :o.aT_respond_to :each end
      assert_nothing_raised do {}.aT_respond_to :each end
      assert_equal( [:hello], [:hello].aT_respond_to( :each ) )
    end
    
    should "have #aT_equal enforcer" do
      assert_raise TErr do 0.aT_equal 1 end
      assert_nothing_raised do 1.aT_equal 2.0/2.0 end
      assert_equal( "hello", "hello".aT_equal( " hello ".strip ) )
    end
    
    should "have #aT_not_equal enforcer" do
      assert_raise TErr do 1.aT_not_equal 1.0 end
      assert_nothing_raised do 7.aT_not_equal 42 end
      assert_equal( "hello", "hello".aT_not_equal( "goodbye" ) )
    end
    
    should "have #aT_blank enforcer" do
      assert_raise TErr do "x".aT_blank end
      assert_nothing_raised do ["", []].each{|e| e.aT_blank } end
      assert_equal( {}, {}.aT_blank )
    end
    
    should "have #aT_present enforcer" do
      assert_raise TErr do nil.aT_present end
      assert_nothing_raised do 0.aT_present end
      assert_equal( "hello", "hello".aT_present )
    end
  end
    
  context "Enumerable" do
    should "have #aT_all enforcer" do
      assert_raise TErr do [1, 2, 7].aT_all { |e| e < 5 } end
      assert_nothing_raised do [1, 2, 4].aT_all { |e| e < 5 } end
    end

    should "have #aT_all_kind_of enforcer" do
      assert_raise TErr do [1.0, 2.0, :a].aT_all_kind_of Numeric end
      assert_nothing_raised do [1.0, 2.0, 3].aT_all_kind_of Numeric end
    end

    should "have #aT_all_comply class compliance enforcer" do
      assert_raise TErr do [1.0, 2.0, :a].aT_all_comply Numeric end
      assert_nothing_raised do [1.0, 2.0, 3].aT_all_comply Numeric end
    end

    should "have #aT_all_numeric enforcer" do
      assert_raise TErr do [:a].aT_all_numeric end
      assert_nothing_raised do [1, 2.0].aT_all_numeric end
    end
    
    should "have #aT_subset_of enforcer" do
      assert_raise TErr do [6].aT_subset_of [*0..5] end
      assert_nothing_raised do [1,2].aT_subset_of [*0..5] end
    end
  end # context Enumerable

  context "Array" do
    should "have #aT_includes (alias #aT_include) enforcer" do
      assert_raise TErr do [1, 2, 4].aT_includes 3 end
      assert_nothing_raised do [1, 2, 4].aT_includes( 4 ).aT_include( 4 ) end
      assert_equal [6, 7], [6, 7].aT_includes( 6 )
      assert_equal [6, 7], [6, 7].aT_include( 6 )
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
      assert_raise TErr do a.merge_synonym_keys!( :a, :b ) end
      assert_equal old, a
      assert_equal true, a.merge_synonym_keys!( :c, :b )
      assert_equal( { a: 'a', c: 'b', k: 'k' }, a )
    end
    
    should "have #may_have synonym key merger" do
      a = { a: 'a', b: 'b', k: 'k', o: 'k', t: 'k' }
      assert_respond_to a, :may_have
      old = a.dup
      assert_nothing_raised do a.may_have :z end
      assert_nothing_raised do a.has? :z end
      assert_raises TErr do a.may_have( :a, syn!: :b ) end
      assert_raises TErr do a.has?( :a, syn!: :b ) end
      assert_equal false, a.has?( :z )
      assert_equal nil, a.may_have( :z )
      assert_equal false, a.has?( :z )
      assert_equal true, a.has?( :a )
      assert_equal a[:a], a.may_have( :a )
      assert_equal true, a.has?( :a )
      assert_equal old, a
      assert_equal 'k', a.may_have( :k, syn!: [:o, :t] )
      assert_equal true, a.has?( :k, syn!: [:o, :t] )
      assert_equal 'b', a.may_have( :c, syn!: :b )
      assert_equal true, a.has?( :c, syn!: :b )
      assert_equal( { a: 'a', c: 'b', k: 'k' }, a )
    end
    
    should "have #aT_has synonymizing enforcer" do
      a = { infile: 'a', csv_out_file: 'b', k: 'k', o: 'k', t: 'k' }
      assert_respond_to a, :aT_has
      old = a.dup
      assert_raises TErr do a.aT_has :z end
      assert_nothing_raised do a.aT_has :infile end
      assert_nothing_raised do a.aT_has :csv_out_file end
      class TestClass; def initialize( args )
                         args.aT_has :infile
                         args.aT_has :csv_out_file
                         args.aT_has :k
                       end end
      assert_nothing_raised do TestClass.new a end
      assert_raises TErr do a.aT_has( :a, syn!: :b ) end
      assert_equal "a", a.aT_has( :infile )
      assert_equal "k", a.aT_has( :k, syn!: [:o, :t] )
      assert_equal "b", a.aT_has( :c, syn!: :csv_out_file )
      assert_equal( { infile: 'a', c: 'b', k: 'k' }, a )
      assert_raises TErr do a.aT_has(:c) {|val| val == 'c'} end
      assert_nothing_raised do a.aT_has(:c) {|val| val == 'b'} end
    end
  end # context Hash
end # class ScruplesTest
