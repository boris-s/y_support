#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'
require 'minitest/spec'
require 'minitest/autorun'
# require 'y_support/all'

class YSupportTest < Test::Unit::TestCase
  context "Object" do
    setup do
      require 'y_support/core_ext/object'
    end

    should "have #const_set_if_not_defined" do
      ( ◉ = Object.new ).const_set_if_not_defined :KOKO, 42
      assert_equal 42, ◉.ⓒ::KOKO
      ◉.const_set_if_not_defined :KOKO, 43
      assert_equal 42, ◉.ⓒ::KOKO
    end

    should "have #const_redef_without_warning" do
      ( ◉ = Object.new ).const_set_if_not_defined :KOKO, 42
      ◉.const_redefine_without_warning :KOKO, 43
      assert_equal 43, ◉.ⓒ::KOKO
    end

#     should "Object have constructors #InertRecorder() and #L() (for LocalObject)" do
#       assert_equal InertRecorder, InertRecorder().class
#       assert_equal LocalObject, ℒ().class
#     end

#     should "have RespondTo() constructor" do
#       assert_equal RespondTo, RespondTo(:inspect).class
#     end
  end # context Object
  
  # context "Module" do
  #   should "have working #attr_accessor_with_default" do
  #     class TestCl; attr_accessor_with_default :hello do "world" end end
  #     testç = TestCl.new
  #     assert_equal( "world", testç.hello )
  #     testç2 = TestCl.new
  #     testç2.hello
  #     testç2.hello = "receiver.jpg"
  #     assert_equal( "receiver.jpg", testç2.hello )
  #   end
    
  #   should "have working autoreq" do
  #     module TestModule
  #       autoreq :fixture_class,
  #         descending_path: '.', ascending_path_prefix: '.'
  #     end
  #     ç = TestModule::FixtureClass
  #     assert_equal( "world", ç.new.hello )
  #   end
  # end # context Module

  # context "Enumerable" do
  #   should "introduce #all_kind_of? collection qualifier" do
  #     assert_equal true, [ 1, 1.0 ].all_kind_of?( Numeric )
  #     assert_equal false, [ 1, [1.0] ].all_kind_of?( Numeric )
  #   end
    
  #   should "introduce #all_numeric? collection qualifier" do
  #     assert_equal true, [1, 1.0].all_numeric?
  #     assert_equal false, [:a, 1].all_numeric?
  #   end
    
  #   should "have #subset_of? collection qualifier" do
  #     assert_equal( true, [1,2].subset_of?( [1,2,3,4] ) )
  #     assert_equal( false, [1,2].subset_of?( [2,3] ) )
  #     assert_equal( true, [1,2].subset_of?( [1,2] ) )
  #     assert_equal( true, [1, 1.0].subset_of?( [1.0, 2.0] ) )
  #   end
  # end # context Enumerable

  # context "Array" do
  #   should "have #to_hash" do
  #     assert_equal( {a: :b, c: :d}, [[:a, :b],[:c, :d]].to_hash )
  #     assert_equal( {k: :kokot, p: :pica}, [[:k, :o, :kokot], [:p, :i, :pica]].to_hash(2) )
  #   end

  #   should "have #each_consecutive_pair iterator" do
  #     assert_kind_of Enumerator, [].each_consecutive_pair
  #     assert_kind_of Enumerator, [:a].each_consecutive_pair
  #     assert_kind_of Enumerator, [:a, :b].each_consecutive_pair
  #     assert_kind_of Enumerator, [:a, :b, :c].each_consecutive_pair
  #     assert_equal [], [].each_consecutive_pair.collect{|e| e }
  #     assert_equal [], [:a].each_consecutive_pair.collect{|e| e }
  #     assert_equal [[:a, :b]], [:a, :b].each_consecutive_pair.collect{|e| e }
  #     assert_equal [[:a, :b], [:b, :c]], [:a, :b, :c].each_consecutive_pair.collect{|e| e }
  #   end

  #   should "have #to_proc in style &[ function, *arguments ]" do
  #     assert_equal [2, 3], [1, 2].map( &[:+, 1] )
  #   end
  # end # context Array

  # context "Hash" do
  #   should "have #default! custom defaulter" do
  #     defaults = { a: 1, b: nil }
  #     test = {}
  #     result = test.default!( defaults )
  #     assert_equal defaults, result
  #     assert_equal result.object_id, test.object_id
  #     test = { a: 11, b: 22 }
  #     assert_equal( { a: 11, b: 22 }, test.default!( defaults ) )
  #     test = { a: 11, c: 22 }
  #     assert_equal( { a: 11, b: nil, c: 22 }, test.default!( defaults ) )
  #   end
    
  #   should "have #with_keys and #modify_keys" do
  #     assert_equal( {"a" => :b, "c" => :d}, {a: :b, c: :d}.with_keys( &:to_s ) )
  #     assert_equal( {"a1" => 1, "c2" => 2}, {a: 1, c: 2}.modify_keys { |k, v|
  #                     k.to_s + v.to_s } )
  #     assert_equal( {"a1" => 1, "c2" => 2}, {a: 1, c: 2}.modify_keys {|p|
  #                     p[0].to_s + p[1].to_s } )
  #     assert_equal( {2 => 1, 4 => 2}, {1 => 1, 2 => 2}.modify_keys { |k, v|
  #                     k + v } )
  #     assert_equal( {2 => 1, 4 => 2}, {1 => 1, 2 => 2}.modify_keys { |p|
  #                     p[0] + p[1] } )
  #   end
    
  #   should "have #with_values and #modify_values" do
  #     assert_equal( { a: "b", c: "d" }, {a: :b, c: :d}.with_values( &:to_s ) )
  #     assert_equal( {a: "ab", c: "cd"}, {a: :b, c: :d}.modify_values { |k, v|
  #                     k.to_s + v.to_s } )
  #     assert_equal( {a: "ab", c: "cd"}, {a: :b, c: :d}.modify_values { |p|
  #                     p[0].to_s + p[1].to_s } )
  #     hh = { a: 1, b: 2 }
  #     hh.with_values! &:to_s
  #     assert_equal ["1", "2"], hh.values
  #     hh.modify_values! &:join
  #     assert_equal ["a1", "b2"], hh.values
  #   end

  #   should "have #modify" do
  #     assert_equal( { ab: "ba", cd: "dc" },
  #                   { a: :b, c: :d }
  #                     .modify { |k, v| ["#{k}#{v}".to_sym, "#{v}#{k}"] } )
  #   end
    
  #   should "have #dot! meta patcher for dotted access to keys" do
  #     h = Hash.new.merge!(aaa: 1, taint: 2)
  #     assert_raise ArgumentError do h.dot! end
  #     assert_nothing_raised do h.dot!( overwrite_methods: true ) end
  #     assert_equal( {aaa: 1}, {aaa: 1}.dot! )
  #   end
  # end # context Hash
  
  # context "Special case objects" do
  #   should "LocalObject exist and comply" do
  #     assert defined? LocalObject
  #     assert_equal Class, LocalObject.class
  #     n = ℒ( 'this msg' )
  #     assert_equal 'this msg', n.signature
  #     assert_equal 'this msg', n.σ
  #   end
  # end # context Special case objects
  
  # context "RespondTo" do
  #   should "work" do
  #     assert defined? RespondTo
  #     assert_respond_to RespondTo.new(:hello), :===
  #       assert RespondTo.new(:each_char) === "hell'o"
  #     assert !( RespondTo.new(:each_char) === Object.new )
  #     assert !( RespondTo.new(:azapat) === Object.new )
  #     assert case ?x; when RespondTo.new(:each_char) then 1 else false end
  #     assert ! case ?x; when RespondTo.new(:azapat) then 1 else false end
  #   end
  # end # context RespondTo
  
  # context "Matrix" do
  #   should "have #pp method" do
  #     assert_respond_to Matrix[[1, 2], [3, 4]], :pretty_print
  #     assert_respond_to Matrix[[1, 2], [3, 4]], :pp
  #   end

  #   should "have #correspondence_matrix method" do
  #     assert_respond_to Matrix, :correspondence_matrix
  #     assert_equal Matrix[[1, 0, 0], [0, 1, 0]],
  #                  Matrix.correspondence_matrix( [:a, :b, :c], [:a, :b] )
  #     assert_equal Matrix.column_vector( [1, 2] ),
  #                  Matrix.correspondence_matrix( [:a, :b, :c], [:a, :b] ) *
  #                    Matrix.column_vector( [1, 2, 3] )
  #     assert_equal 2, Matrix.correspondence_matrix( [1, 2], [1] ).column_size
  #   end

  #   should "have #column_to_a & #row_to_a" do
  #     assert_equal [1, 2, 3], Matrix[[1], [2], [3]].column_to_a
  #     assert_equal [2, 3, 4], Matrix[[1, 2], [2, 3], [3, 4]].column_to_a( 1 )
  #     assert_equal nil, Matrix.empty( 5, 0 ).column_to_a
  #     assert_equal [1], Matrix[[1], [2], [3]].row_to_a
  #     assert_equal [3], Matrix[[1], [2], [3]].row_to_a( 2 )
  #   end

  #   should "have aliased #row_vector, #column_vector methods" do
  #     assert_equal Matrix.column_vector( [1, 2, 3] ),
  #                  Matrix.cv( [1, 2, 3] )
  #     assert_equal Matrix.row_vector( [1, 2, 3] ),
  #                  Matrix.rv( [1, 2, 3] )
  #   end

  #   should "have #join_bottom and #join_right" do
  #     assert_equal Matrix[[1, 2], [3, 4]],
  #                  Matrix[[1, 2]].join_bottom( Matrix[[3, 4]] )
  #     assert_equal Matrix[[1, 2, 3, 4]],
  #                  Matrix[[1, 2]].join_right( Matrix[[3, 4]] )
  #   end

  #   should "have aliased #row_size, #column_size methods" do
  #     assert_equal 3, Matrix.zero(3, 2).height
  #     assert_equal 3, Matrix.zero(3, 2).number_of_rows
  #     assert_equal 2, Matrix.zero(3, 2).width
  #     assert_equal 2, Matrix.zero(3, 2).number_of_columns
  #   end
  # end # context Matrix
  
  # context "String" do
  #   should "have #can_be_integer? returning the integer or false if not convertible" do
  #     assert_equal 33, "  33".to_Integer
  #     assert_equal 8, " 010 ".to_Integer
  #     assert_equal false, "garbage".to_Integer
  #   end
    
  #   should "have #can_be_float? returning the float or false if not convertible" do
  #     assert_equal 22.2, ' 2.22e1'.to_Float
  #     assert_equal 10, " 010 ".to_Float
  #     assert_equal false, "garbage".to_Float
  #   end
    
  #   should "have #default! defaulter" do
  #     assert_equal "default", "".default!("default")
  #     assert_equal "default", " ".default!(:default)
  #     assert_equal "default", " \n ".default!("default")
  #     assert_equal "kokot", "kokot".default!("default")
  #     a = ""
  #     assert_equal a.object_id, a.default!("tata").object_id
  #   end
    
  #   should "have #stripn upgrade of #strip, which also strips newlines" do
  #     assert_equal "test test", " \n test test \n\n  \n ".stripn
  #   end
    
  #   should "have #compact for joining indented lines (esp. heredocs)" do
  #     assert_equal "test test test",
  #                  "test\n test\n\n   \n   test\n  ".wring_heredoc
  #     funny_string = <<-FUNNY_STRING.wring_heredoc
  #                       This
  #                         is
  #                           a funny string.
  #                       FUNNY_STRING
  #     assert_equal( 'This is a funny string.', funny_string )
  #   end
    
  #   should "be able #underscore_spaces" do
  #     assert_equal "te_st_test", "te st test".underscore_spaces
  #   end
    
  #   should "have #symbolize stripping, removing capitalization and diacritics " \
  #   'as if to make a suitable symbol material' do
  #     assert_equal "Yes_sir!", " \nYes, sir!.; \n \n".standardize
  #   end
    
  #   should "have #to_standardized_sym chaining #standardize and #to_sym" do
  #     assert_equal :Yes,  " \nYes,.; \n \n".to_standardized_sym
  #   end
  # end # context String

  # context "Symbol" do
  #   should "have #default! defaulter going through String#default!" do
  #     assert_equal :default, "".to_sym.default!(:default)
  #     assert_equal :default, "".to_sym.default!("default")
  #     assert_equal :default, " ".to_sym.default!("default")
  #     assert_equal :default, " \n ".to_sym.default!("default")
  #     assert_equal :kokot, :kokot.default!("default")
  #   end
    
  #   should "have #to_standardized_sym" do
  #     assert_equal :Yes, (:" \nYes, \n").to_standardized_sym
  #   end
    
  #   should "have Symbol#~@ for .respond_to? case statements" do
  #     assert_kind_of RespondTo, ~:hello
  #     assert RespondTo(:<<) === "testing"
  #     assert case ?x; when ~:each_char then 1 else false end
  #     assert !case ?x; when ~:azapat then 1 else false end
  #   end
  # end # context Symbol

  # context "Numeric" do
  #   should "have #zero public class methods" do
  #     assert_equal 0, Integer.zero
  #     assert_equal 0.0, Float.zero
  #     assert_equal Complex(0, 0), Complex.zero
  #   end
  # end
end # class YSupportTest
