#! /usr/bin/ruby
# encoding: utf-8

require 'minitest/autorun'
require_relative '../lib/y_support/flex_coerce'

describe "user class that defines no coercion whatsoever" do
  before do
    @c = Class.new do include FlexCoerce end
  end
  
  it "must be extended by FlexCoerce::ClassMethods" do
    @c.singleton_class.ancestors.must_include FlexCoerce::ClassMethods
  end

  it "must have a parametrized subclass of FlexProxy" do
    assert @c.FlexProxy < FlexCoerce::FlexProxy
    @c.FlexProxy.host_class.must_equal @c
  end

  describe "object of that class" do
    before do
      @object = @c.new
    end

    it "should provide to the user class #coerce method returning a proxy" do
      o1, o2 = @object.coerce 42
      o1.must_be_kind_of FlexCoerce::FlexProxy
      o2.must_equal @object
    end

    it "should raise TypeError for all operators and binary methods" do
      -> { 42 + @object }.must_raise TypeError
      -> { 42 - @object }.must_raise TypeError
      -> { 42 * @object }.must_raise TypeError
      -> { 42 / @object }.must_raise TypeError
      -> { 42 % @object }.must_raise TypeError
      -> { 42.div @object }.must_raise TypeError
      -> { 42.divmod @object }.must_raise TypeError
      -> { 42.fdiv @object }.must_raise TypeError
      -> { 42 ** @object }.must_raise TypeError
      -> { 42 & @object }.must_raise TypeError
      -> { 42 | @object }.must_raise TypeError
      -> { 42 ^ @object }.must_raise TypeError
      -> { 42 > @object }.must_raise TypeError
      -> { 42 >= @object }.must_raise TypeError
      -> { 42 < @object }.must_raise TypeError
      -> { 42 <= @object }.must_raise TypeError
      -> { 42 <=> @object }.must_raise TypeError
      # Operator #=== is too liberal to call #coerce.
      -> { @object.coerce( 42 ).first === @object }.must_raise TypeError
    end
  end
end

describe "user class that allows Numeric#* and nothing else" do
  before do
    @c = Class.new do
      include FlexCoerce
      def + number; 10 + number end
      def - number; 10 - number end
      def * number; 10 * number end
      def / number; 10 / number end
    end

    @c.define_coercion Fixnum, method: :* do |left_operand, right_operand|
      right_operand * left_operand
    end
  end

  it "must have coercion table with :* entry" do
    @c.coercion_table.keys.must_equal [ :* ]
    table_entry = @c.FlexProxy.new( 42 ).host_class.coercion_table[ :* ]
    table_entry.size.must_equal 1
    table_entry.find { |type, closure| type === 42 }.must_be_kind_of Array
    assert table_entry.find { |type, _| type == :foobar }.nil?
  end

  describe "object of that class" do
    before do
      @object = @c.new
    end

    it "is defined to behave as number 10 with 4 basic operators" do
      ( @object + 2 ).must_equal 12
      ( @object - 2 ).must_equal 8
      ( @object * 2 ).must_equal 20
      ( @object / 2 ).must_equal 5
    end

    it "must have working coercion with  Fixnum#*, but not other classes" do
      ( 2 * @object ).must_equal 20
      ( 3 * @object ).must_equal 30
      -> { 3.0 * @object }.must_raise TypeError
    end

    it "should not define coercion for other operators" do
      -> { 42 + @object }.must_raise TypeError
      -> { 42 - @object }.must_raise TypeError
      -> { 42 / @object }.must_raise TypeError
      -> { 42 % @object }.must_raise TypeError
    end
  end
end

describe "class that includes FlexCoerce via another module" do
  before do
    m = Module.new do include FlexCoerce end
    @c = Class.new do
      include m
      def + arg; 10 + arg end
    end
  end

  it "should still allow defining coercion" do
    @c.methods.must_include :define_coercion
  end

  describe "object of such class" do
    before do
      @c.define_coercion Integer, method: :+ do |operand_1, operand_2|
        operand_2 + operand_1
      end
      @object = @c.new
    end

    it "should function as expected" do
      ( 1 + @c.new ).must_equal 11
    end
  end
end
   


