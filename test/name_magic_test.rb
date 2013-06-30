#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'
require 'minitest/spec'
require 'minitest/autorun'
require 'y_support/name_magic'

describe NameMagic do
  before do
    mod = Module.new do include NameMagic end
    @ç = Class.new do include mod end
    @reporter = Object.new
    puts "..."
    @reporter.singleton_class.class_exec { attr_reader :report, :naming }
    @ç.namespace.new_instance_closure do |instance|
      @reporter.define_singleton_method :report do "Instance reported" end
    end
    @ç.namespace.name_set_closure do |name, instance, old_name|
      @reporter.define_singleton_method :name_set do
        "Name of the new instance was #{name}"
      end
      name
    end
    @ç.name_get_closure do |name_object|
      @reporter.define_singleton_method :name_get do
        "Name get closure called on #{name_object}"
      end
      name_object
    end
  end
  
  it "should work" do
    @ç.must_respond_to :const_magic
    @ç.instances.must_be_empty
    @ç.nameless_instances.must_be_empty
    @reporter.report.must_equal nil
    x = @ç.new( name: "Boris" )
    @reporter.report.must_equal "Instance reported"
    @reporter.name_set.must_equal "Name of the new instance was Boris"
    x.name.must_equal :Boris
    @reporter.name_get.must_equal "Name get closure called on Boris"
    ufo = @ç.new
    @ç.nameless_instances.must_equal [ufo]
    UFO = @ç.new
    @reporter.report.must_equal "Instance reported"
    @reporter.name_set.must_equal "Name of the new instance was Boris"
    UFO.name
    @reporter.name_set.must_equal "Name of the new instance was UFO"
    @reporter.name_get.must_equal "Name get closure called on UFO"
    Elaine = @ç.new
    Elaine.name.must_equal :Elaine
    m = Module.new
    XXX = m
    @ç.namespace = XXX
    @ç.namespace.must_equal m
    Rover = @ç.new
    @ç.const_magic
    XXX::Rover.must_be_kind_of @ç
    @ç.namespace!
    Spot = @ç.new
    @ç.const_magic
    -> { XXX::Spot }.must_raise NameError
    @ç.const_get( :Spot ).must_be_kind_of @ç
  end
end
