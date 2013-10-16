#! /usr/bin/ruby
#encoding: utf-8

require 'minitest/autorun'
require 'y_support/name_magic'

describe NameMagic do
  before do
    mod = Module.new do include NameMagic end
    @ç = Class.new do include mod end
    @reporter = Object.new
    puts "..."
    @reporter.singleton_class.class_exec { attr_reader :report, :naming }
    @ç.ancestors.must_include NameMagic
    @ç.singleton_class.ancestors.must_include NameMagic::ClassMethods
    @ç.namespace.new_instance_hook do |instance|
      @reporter.define_singleton_method :report do "Instance reported" end
    end
    @ç.namespace.name_set_hook do |name, instance, old_name|
      @reporter.define_singleton_method :name_set do
        "Name of the new instance was #{name}"
      end
      name
    end
    @ç.name_get_hook do |name_object|
      @reporter.define_singleton_method :name_get do
        "Name get hook called on #{name_object}"
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
    @reporter.name_get.must_equal "Name get hook called on Boris"
    ufo = @ç.new
    @ç.nameless_instances.must_equal [ufo]
    UFO = @ç.new
    @reporter.report.must_equal "Instance reported"
    @reporter.name_set.must_equal "Name of the new instance was Boris"
    UFO.name
    @reporter.name_set.must_equal "Name of the new instance was UFO"
    @reporter.name_get.must_equal "Name get hook called on UFO"
    Elaine = @ç.new
    Elaine.name.must_equal :Elaine
    m = Module.new
    XXX = m
    @ç.namespace = XXX
    @ç.namespace.must_equal m
    @ç.singleton_class.must_include ::NameMagic::ClassMethods
    m.singleton_class.must_include ::NameMagic::NamespaceMethods
    Rover = @ç.new
    @ç.namespace.must_equal XXX
    @ç.nameless_instances.must_equal [ Rover ]
    @ç.const_magic
    Rover.name.must_equal :Rover
    XXX::Rover.must_be_kind_of @ç
    @ç.namespace!
    Spot = @ç.new
    @ç.const_magic
    Spot.name.must_equal :Spot
    -> { XXX::Spot }.must_raise NameError
    @ç.const_get( :Spot ).must_be_kind_of @ç
    # Array
    [ Spot ].names.must_equal [ :Spot ]
    { Spot => 42 }.keys_to_names.must_equal( { Spot: 42 } )
  end
end    
