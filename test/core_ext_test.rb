#! /usr/bin/ruby
# encoding: utf-8

require 'minitest/autorun'

describe Object do
  before do
    require './../lib/y_support/core_ext/object'
  end

  it "should have #param_class" do
    o = Object.new
    m = Module.new
    o.param_class( { Array: Array, foo: Hash, bar: m }, with: { mother: o } )
    assert o.Array < Array
    o.Array.mother.must_equal( o )
    o.foo.mother.must_equal( o )
    o.bar.ancestors[1].must_equal( m )
    o.bar.mother.must_equal( o )
  end

  it "should have #param_class!" do
    o = Object.new
    m = Module.new
    o.param_class!( { Array: Array, foo: Hash, bar: m }, with: { mother: o } )
    assert o.Array < Array
    o.Array.mother.must_equal( o )
    o.foo.mother.must_equal( o )
    o.bar.ancestors[1].must_equal( m )
    o.bar.mother.must_equal( o )
  end

  it "should have #insp method to facilitate inspection" do
    module Quux; class Foo; def to_s; "bar" end end end
    Quux::Foo.new.y_inspect.must_equal "Quux::Foo:bar"
    Quux::Foo.new.y_inspect( :full ).must_equal "#<Quux::Foo:bar>"
    Quux::Foo.new.y_inspect( :short ).must_equal "Foo:bar"
  end
end


describe Module do
  before do
    require './../lib/y_support/core_ext/module'
  end

  it "has #const_set_if_not_defined and #const_reset!" do
    m = Module.new
    hm = m.heir_module( p1: 1, p2: 2 )
    hm.ancestors[1].must_equal m
    hm.p1.must_equal 1
    hm.p2.must_equal 2
    hc = m.heir_class( Array, q1: 1, q2: 2 )
    hc.new.class.ancestors[1].must_equal m
    hc.q1.must_equal 1
    hc.q2.must_equal 2
    m.const_set_if_not_defined :Foo, 42
    m::Foo.must_equal 42
    m.const_reset! :Foo, 43
    m::Foo.must_equal 43
    m.module_exec do
      selector :a
      def initialize; @a = 42 end
      chain b: :a, &:to_s
    end
    Class.new do include m end.new.b.must_equal "42"
  end
end

describe Class do
  before do
    require './../lib/y_support/core_ext/class'
  end

  it "has #selector alias for #attr_reader method" do
    o = Class.new do
      selector :a
      def initialize a; @a = a end
    end.new( 42 )
    o.a.must_equal( 42 )
  end

  it "has #parametrize method" do
    a = Class.new
    -> { a.foo }.must_raise NoMethodError
    b = a.parametrize foo: 42
    b.foo.must_equal 42
  end
end


describe Enumerable do
  before do
    require './../lib/y_support/core_ext/enumerable'
  end

  it "should introduce #all_kind_of? collection qualifier" do
    assert_equal true, [ 1, 1.0 ].all_kind_of?( Numeric )
    assert_equal false, [ 1, [1.0] ].all_kind_of?( Numeric )
  end
    
  it "should introduce #all_numeric? collection qualifier" do
    assert_equal true, [1, 1.0].all_numeric?
    assert_equal false, [:a, 1].all_numeric?
  end

  it "should have #subset_of? collection qualifier" do
    assert_equal( true, [1,2].subset_of?( [1,2,3,4] ) )
    assert_equal( false, [1,2].subset_of?( [2,3] ) )
    assert_equal( true, [1,2].subset_of?( [1,2] ) )
    assert_equal( true, [1, 1.0].subset_of?( [1.0, 2.0] ) )
  end
end


describe Array do
  before do
    require './../lib/y_support/core_ext/array'
  end

  it "has #arrays_to_hash" do
    [ [ :a, 1 ], [ :b, 2 ] ].arrays_to_hash
      .must_equal( { a: 1, b: 2 } )
    [ [ :a, 1, 2 ], [ :b, 2, 3 ] ].arrays_to_hash
      .must_equal( { a: [ 1, 2 ], b: [ 2, 3 ] } )
  end

  it "has #zip_to_hash" do
    assert_equal( {a: 1, b: 2}, [:a, :b].zip_to_hash( [1, 2] ) )
    assert_equal( {a: "a"}, [:a].zip_to_hash( &:to_s ) )
  end

  it "has #>>" do
    assert_equal( {a: 1, b: 2}, [:a, :b] >> [1, 2] )
  end

  it "has #ascending_floor" do
    a = 1, 2, 3
    a.ascending_floor( 0.5 ).must_equal nil
    a.ascending_floor( 1 ).must_equal 1
    a.ascending_floor( 1.5 ).must_equal 1
    a.ascending_floor( 3.5 ).must_equal 3
    a.ascending_floor( 1, false ).must_equal nil
    a.ascending_floor( 3, false ).must_equal 2
  end

  it "has #ascending_ceiling" do
    a = 1, 2, 3
    a.ascending_ceiling( 0.5 ).must_equal 1
    a.ascending_ceiling( 1.5 ).must_equal 2
    a.ascending_ceiling( 3 ).must_equal 3
    a.ascending_ceiling( 3.1 ).must_equal nil
    a.ascending_ceiling( 3, false ).must_equal nil
    a.ascending_ceiling( 2, false ).must_equal 3
  end

  it "has #to_proc in style &[function, *args]" do
    assert_equal [2, 3], [1, 2].map( &[:+, 1] )
  end

  it "has #push/pop_ordered/named" do
    a = [1, 2, foo: 3]
    a.pop_named( :foo ).must_equal 3
    a.pop_named( :bar ).must_equal nil
    a.pop_ordered.must_equal 2
    a.push_ordered( 2 ).must_equal [1, 2]
    a.push_named( foo: 3 ).must_equal [1, 2, foo: 3]
    a.push_named( bar: 4 ).must_equal [1, 2, foo: 3, bar: 4]
    a.pop_named( :foo ).must_equal 3
    a.push_ordered( 42 ).must_equal [1, 2, 42, bar: 4] 
  end

  it "has #to_column_vector" do
    [1, 2, 3].to_column_vector.must_equal Matrix[[1], [2], [3]]
  end
end

describe Hash do
  before do
    require './../lib/y_support/core_ext/hash'
  end

  it "should have #default! custom defaulter" do
    defaults = { a: 1, b: nil }
    test = {}
    result = test.default!( defaults )
    assert_equal defaults, result
    assert_equal result.object_id, test.object_id
    test = { a: 11, b: 22 }
    assert_equal( { a: 11, b: 22 }, test.default!( defaults ) )
    test = { a: 11, c: 22 }
    { a: 11, b: nil, c: 22 }.must_equal test.default! defaults
  end

  it "should have #with_keys and #with_keys!" do
    test = { "a" => :b, "c" => :d }
    test.with_keys( &:to_sym ).must_equal( { a: :b, c: :d } )
    test.must_equal( { "a" => :b, "c" => :d } )
    test.with_keys! &:to_sym
    test.must_equal( { a: :b, c: :d } )
  end

  it "should have #change_keys" do
    test = { a: 1, c: 2 }
    test.change_keys { |k, v| k.to_s + v.to_s }
      .must_equal( { "a1" => 1, "c2" => 2 } )
  end

  it "should have #with_values and #with_values!" do
    test = { a: :b, c: :d }
    test.with_values( &:to_s ).must_equal( { a: "b", c: "d" } )
    test.must_equal( { a: :b, c: :d } )
    test.with_values!( &:to_s )
    test.must_equal( { a: "b", c: "d" } )
  end

  it "should have #change_values and #change_values!" do
    test = { a: :b, c: :d }
    test.modify_values do |k, v| k.to_s + v.to_s end
      .must_equal( {a: "ab", c: "cd"} )
    test.must_equal( { a: :b, c: :d } )
    test.modify_values! { |k, v| k.to_s + v.to_s }
    test.must_equal( {a: "ab", c: "cd"} )
  end

  it "should have #modify" do
    assert_equal( { ab: "ba", cd: "dc" },
                  { a: :b, c: :d }
                    .modify { |k, v| ["#{k}#{v}".to_sym, "#{v}#{k}"] } )
  end

  it "should have #slice" do
    { a: 1, b: 2, c: 3 }.slice( [:a, :b] ).must_equal( { a: 1, b: 2 } )
    { 1 => :a, 2 => :b, 3 => :c, 4 => :d }.slice( 2..3.5 )
      .must_equal( { 2 => :b, 3 => :c } )
    { 0.0 => :a, 1.1 => :b }.slice( 1..2 ).must_equal( { 1.1 => :b } )
  end

  it "should have #dot! meta patcher for dotted access to keys" do
    h = Hash.new.merge!(aaa: 1, taint: 2)
    -> { h.dot! }.must_raise ArgumentError
    h.dot!( overwrite_methods: true ) # instead of #assert_nothing_raised
    assert_equal( {aaa: 1}, {aaa: 1}.dot! )
  end

  it "should be safeguarded against redefining #slice" do
    m = Hash.instance_method :slice
    class Hash; def slice( *args ); fail "This should not happen!" end end
    {}.slice( :a )
  end
end


describe "Matrix" do
  before do
    require 'matrix'
    require './../lib/y_support/stdlib_ext/matrix'
  end

  it "should have #pp method" do
    assert_respond_to Matrix[[1, 2], [3, 4]], :pretty_print
    assert_respond_to Matrix[[1, 2], [3, 4]], :pp
  end

  it "should have #correspondence_matrix method" do
    assert_respond_to Matrix, :correspondence_matrix
    assert_equal Matrix[[1, 0, 0], [0, 1, 0]],
    Matrix.correspondence_matrix( [:a, :b, :c], [:a, :b] )
    assert_equal Matrix.column_vector( [1, 2] ),
    Matrix.correspondence_matrix( [:a, :b, :c], [:a, :b] ) *
      Matrix.column_vector( [1, 2, 3] )
    assert_equal 2, Matrix.correspondence_matrix( [1, 2], [1] ).column_size
  end

  it "should have #column_to_a & #row_to_a" do
    assert_equal [1, 2, 3], Matrix[[1], [2], [3]].column_to_a
    assert_equal [2, 3, 4], Matrix[[1, 2], [2, 3], [3, 4]].column_to_a( 1 )
    assert_equal nil, Matrix.empty( 5, 0 ).column_to_a
    assert_equal [1], Matrix[[1], [2], [3]].row_to_a
    assert_equal [3], Matrix[[1], [2], [3]].row_to_a( 2 )
  end

  it "should have aliased #row_vector, #column_vector methods" do
    assert_equal Matrix.column_vector( [1, 2, 3] ),
    Matrix.cv( [1, 2, 3] )
    assert_equal Matrix.row_vector( [1, 2, 3] ),
    Matrix.rv( [1, 2, 3] )
  end

  it "should have #join_bottom and #join_right" do
    assert_equal Matrix[[1, 2], [3, 4]],
    Matrix[[1, 2]].join_bottom( Matrix[[3, 4]] )
    assert_equal Matrix[[1, 2, 3, 4]],
    Matrix[[1, 2]].join_right( Matrix[[3, 4]] )
  end

  it "should have aliased #row_size, #column_size methods" do
    assert_equal 3, Matrix.zero(3, 2).height
    assert_equal 3, Matrix.zero(3, 2).number_of_rows
    assert_equal 2, Matrix.zero(3, 2).width
    assert_equal 2, Matrix.zero(3, 2).number_of_columns
  end
end

describe String do
  before do
    require './../lib/y_support/core_ext/string'
  end

  it "should have #can_be_integer? returning the integer or false if not convertible" do
    assert_equal 33, "  33".to_Integer
    assert_equal 8, " 010 ".to_Integer
    assert_equal false, "garbage".to_Integer
  end

  it "should have #can_be_float? returning the float or false if not convertible" do
    assert_equal 22.2, ' 2.22e1'.to_Float
    assert_equal 10, " 010 ".to_Float
    assert_equal false, "garbage".to_Float
  end

  it "should have #default! defaulter" do
    assert_equal "default", "".default!("default")
    assert_equal "default", " ".default!(:default)
    assert_equal "default", " \n ".default!("default")
    assert_equal "kokot", "kokot".default!("default")
    a = ""
    assert_equal a.object_id, a.default!("tata").object_id
  end

  it "should have #stripn upgrade of #strip, which also strips newlines" do
    assert_equal "test test", " \n test test \n\n  \n ".stripn
  end

  it "should have #compact for joining indented lines (esp. heredocs)" do
    assert_equal "test test test",
    "test\n test\n\n   \n   test\n  ".wring_heredoc
    funny_string = <<-FUNNY_STRING.wring_heredoc
                        This
                          is
                            a funny string.
                        FUNNY_STRING
    assert_equal( 'This is a funny string.', funny_string )
  end

  it "should be able #underscore_spaces" do
    assert_equal "te_st_test", "te st test".underscore_spaces
  end

  it "should have #symbolize stripping, removing capitalization and diacritics " \
  'as if to make a suitable symbol material' do
    assert_equal "Yes_sir!", " \nYes, sir!.; \n \n".standardize
  end

  it "should have #to_standardized_sym chaining #standardize and #to_sym" do
    assert_equal :Yes,  " \nYes,.; \n \n".to_standardized_sym
  end
end


describe Symbol do
  before do
    require './../lib/y_support/core_ext/symbol'
  end

  it "should have #default! defaulter going through String#default!" do
    assert_equal :default, "".to_sym.default!(:default)
    assert_equal :default, "".to_sym.default!("default")
    assert_equal :default, " ".to_sym.default!("default")
    assert_equal :default, " \n ".to_sym.default!("default")
    assert_equal :kokot, :kokot.default!("default")
  end

  it "should have #to_standardized_sym" do
    assert_equal :Yes, (:" \nYes, \n").to_standardized_sym
  end
end

describe Numeric do
  before do
    require './../lib/y_support/core_ext/numeric'
  end

  it "should have #zero public class methods" do
    assert_equal 0, Integer.zero
    assert_equal 0.0, Float.zero
    assert_equal Complex(0, 0), Complex.zero
  end
end
