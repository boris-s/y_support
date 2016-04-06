#! /usr/bin/ruby
#encoding: utf-8

require 'minitest/autorun'
require './../lib/y_support/name_magic'

describe NameMagic do
  before do
    @c = -> { mod = Module.new do include NameMagic end
              Class.new do include mod end }
  end

  describe NameMagic::ClassMethods do
    it "should carry certain instance methods" do
      [ :__instances__,
        :__avid_instances__,
        :const_magic,
        :validate_name,
        :namespace=,
        :namespace!,
        :instances,
        :instance,
        :nameless_instances,
        :forget,
        :__forget__,
        :forget_nameless_instances,
        :forget_all_instances,
        :instantiation_exec,
        :exec_when_naming,
        :new,
      ].each { |ß|
        NameMagic::ClassMethods.instance_methods.must_include ß
      }
    end

    describe ".__instances__" do
      it "must act as a selector of the instance registry" do
        c = @c.call
        c.__instances__.must_be_kind_of Hash
        c.__instances__.must_be_empty
        i1 = c.new
        c.__instances__.to_a.first.must_equal [ i1, nil ]
        i2 = c.new name: "Joe"
        c.__instances__.must_equal( { i1 => nil, i2 => :Joe } )
      end
    end
    
    describe ".__avid_instances__" do
      it "must return the avid (typically unnamed) instances" do
        c = @c.call
        c.__avid_instances__.must_equal []
        instance = c.new
        c.__avid_instances__.must_equal [ instance ]
      end
    end

    describe ".validate_name" do
      it "must validate suitable capitalized names" do
        c = @c.call
        c.validate_name( :Fred ).must_equal "Fred"
        c.validate_name( "Fred" ).must_equal "Fred"
        -> { c.validate_name "fred" }.must_raise NameError
        -> { c.validate_name "Name With Spaces" }
          .must_raise NameError
      end
    end

    describe ".namespace" do
      it "should return namespace of the user class" do
        c = @c.call
        c.namespace.must_equal c
      end
    end

    describe ".namespace=" do
      it "shoud can redefine the namespace of a class" do
        c, m = @c.call, Module.new
        d = Class.new c
        c.namespace.must_equal c
        c.namespace = m
        c.namespace.must_equal m
        d.namespace.must_equal m
        c, m = @c.call, Module.new
        d = Class.new c
        d.namespace.must_equal c
        d.namespace = m
        c.namespace.must_equal c
      end

      it "raises error when instance registry is not empty" do
        c, m = @c.call, Module.new
        c.new
        -> { c.namespace = m }.must_raise StandardError
      end
    end

    describe ".namespace!" do
      it "should work" do
        c = @c.call
        subclass = Class.new c
        refute subclass.namespace == subclass
        subclass.namespace!
        assert subclass.namespace == subclass
      end
    end

    describe "instance selectors" do
      before do
        @human = @c.call
        @saint = Class.new @human
        @joe = @human.new name: "Joe"
        @dick = @saint.new name: "St_IGNUcius"
      end

      describe ".instances" do
        it "must return the list of instances in the registry" do
          @human.instances.must_equal [ @joe, @dick ]
          @saint.instances.must_equal [ @dick ]
        end
      end

      describe ".instance" do
        it "must return instance reference" do
          -> { @saint.instance @joe }.must_raise NameError
          -> { @saint.instance :Joe }.must_raise NameError
          @human.instance( @joe ).must_equal @joe
          @human.instance( :Joe ).must_equal @joe
          @saint.instance( @dick ).must_equal @dick
          @saint.instance( :St_IGNUcius ).must_equal @dick
          @human.instance( @dick ).must_equal @dick
          @human.instance( :St_IGNUcius ).must_equal @dick
        end
      end

      describe ".nameless_instances" do
        it "returns the list of registered nameless instances" do
          c = @c.call
          d = Class.new c
          c.nameless_instances.must_equal []
          i1 = c.new
          c.nameless_instances.must_equal [ i1 ]
          d.nameless_instances.must_equal []
          i2 = d.new
          c.nameless_instances.must_equal [ i1, i2 ]
          d.nameless_instances.must_equal [ i2 ]
          i1.name = :Foo
          c.nameless_instances.must_equal [ i2 ]
          d.nameless_instances.must_equal [ i2 ]
          i2.name = :Bar
          c.nameless_instances.must_equal []
          d.nameless_instances.must_equal []
        end
      end
    end

    describe "forgetting instances" do
      before do
        @human = @c.call
        @saint = Class.new @human
        @joe = @human.new name: "Joe"
        @dick = @saint.new name: "St_IGNUcius"
      end

      describe ".forget" do
        it "should clear the given instance from the registry" do
          -> { @saint.forget @joe }.must_raise NameError
          @human.forget( :Joe ).must_equal @joe
          @saint.forget( @dick ).must_equal @dick
          @human.instances.must_equal []
        end
      end

      describe ".__forget__" do
        it "shoulf forget instance without doing #const_magic" do
          -> { @saint.__forget__ @joe }.must_raise TypeError
          -> { @human.__forget__ :Joe }.must_raise TypeError
          @saint.__forget__( @dick ).must_equal :St_IGNUcius
          i = @saint.new
          @saint.__forget__( i ).must_equal nil
        end
      end

      describe ".forget_nameless_instances" do
        it "should unregister anonymous instances" do
          i, j = @human.new, @human.new
          @human.nameless_instances.must_equal [ i, j ]
          Fred = i
          @human.forget_nameless_instances
          @human.instances.must_equal [ @joe, @dick, i ]
        end
      end

      describe ".forget_all_instances" do
        it "should unregister all instances" do
          @saint.forget_all_instances
          @human.instances.must_equal [ @joe ]
          @human.forget_all_instances
          @human.instances.must_equal []
        end
      end
    end

    describe ".new with :name/:ɴ parameters supplied" do
      it "should work" do
        c = @c.call
        i1 = c.new name: :Fred
        i1.name.must_equal :Fred
        i2 = c.new name: "Joe"
        i2.name.must_equal :Joe
      end
    end

    describe ".new with name!: parameter supplied" do
      it "must steal names of other instances" do
        c = @c.call
        i1 = c.new name: "Joe"
        i1.name.must_equal :Joe
        -> { c.new name: "Joe" }.must_raise NameError
        i2 = c.new name!: "Joe"
        i2.name.must_equal :Joe
        i1.name.must_equal nil
        -> { c.new name: "Joe", name!: "Joe" }
          .must_raise ArgumentError
        -> { c.new name!: "Joe", avid: nil }
          .must_raise ArgumentError
      end
    end
  end # describe NameMagic::ClassMethods

  describe ".instantiation_exec hook" do
    it "must execute upon instantiation" do
      c = @c.call
      object_ids = []
      c.instantiation_exec do |instance|
        object_ids << instance.object_id
      end
      i1 = c.new
      object_ids.size.must_equal 1
      i2 = c.new
      object_ids.size.must_equal 2
      object_ids.must_equal [ i1.object_id, i2.object_id ]
    end
  end

  describe ".exec_when_naming hook" do
    it "must execute at baptism and allow name censorship" do
      c = @c.call
      baptised_instances = []
      discarded_names = []
      c.exec_when_naming do |name, instance, old_name|
        baptised_instances << instance
        discarded_names << old_name if old_name
        # Censor the name.
        name.end_with?( "gnucius" ) ? "St_IGNUcius" : name
      end
      c.new name: :Joe
      c.new name: :Dave
      baptised_instances
        .must_equal [ c.instance( :Joe ), c.instance( :Dave ) ]
      discarded_names.must_equal []
      c.instance( :Dave ).name = "Ignucius"
      baptised_instances.names
        .must_equal [ :Joe, :St_IGNUcius, :St_IGNUcius ]
      discarded_names.must_equal [ :Dave ]
    end
  end

  describe NameMagic::Namespace do
    before do
      @human = @c.call
      @saint = Class.new @human
      @ns = Module.new
      @human.namespace = @ns
    end

    it "should carry certain instance methods" do
      [ :instances,
        :__instances__,
        :__avid_instances__,
        :instance,
        :const_magic,
        :nameless_instances,
        :forget,
        :__forget__,
        :forget_nameless_instances,
        :forget_all_instances,
        :instantiation_exec,
        :exec_when_naming,
        :validate_name
      ].each { |ß|
        NameMagic::Namespace.instance_methods.must_include ß
      }
      NameMagic::Namespace.private_instance_methods
        .must_include :search_all_modules
    end

    describe "Namespace#instances" do
      it "should work as expected" do
        @ns.instances.must_equal []
        @saint.new
        @ns.instances.size.must_equal 1
      end
    end

    describe "Namespace#__instances__" do
      it "should work as expected" do
        @ns.__instances__.must_equal( {} )
        @saint.new
        @ns.__instances__.size.must_equal 1
      end
    end

    describe "Namespace#__avid_instances__" do
      it "should work as expected" do
        @ns.__avid_instances__.must_equal []
        @saint.new
        @ns.__avid_instances__.size.must_equal 1
      end
    end

    describe "Namespace#instance" do
      it "should work as expected" do
        -> { @ns.instance( :foo ) }.must_raise NameError
        @saint.new name: :Dave
        @ns.instance( :Dave ).must_be_kind_of @saint
      end
    end

    describe "Namespace#const_magic" do
      it "should manually trigger constant magic" do
        registry = @ns.__instances__
        registry.size.must_equal 0
        m = Module.new
        # New instance is assigned to the constant "Dave", but
        # Namespace#const_magic is not triggered automatically.
        m::Dave = @saint.new
        registry.size.must_equal 1
        instance, name = registry.to_a.first
        assert name.nil?
        # Up until this point, #const_magic was not triggered,
        # because no methods triggering it were invoked. In
        # everyday use of NameMagic, this rarely happens, but
        # should it ever happen, we can trigger #const_magic
        # manually:
        @ns.const_magic
        # Now the instance already knows its name:
        instance, name = registry.to_a.first
        name.must_equal :Dave
      end
    end

    describe "Namespace#nameless_instances" do
      it "should work as expected" do
        @ns.nameless_instances.must_equal []
        @human.new
        @ns.nameless_instances.size.must_equal 1
        @ns.instances.first.name = "Fred"
        @ns.nameless_instances.must_equal []
      end
    end

    describe "Namespace#forget" do
      it "should work as expected" do
        i = @human.new name: :Fred
        @ns.instances.size.must_equal 1
        @ns.forget :Fred
        @ns.instances.size.must_equal 0
      end
    end

    describe "Namespace#__forget__" do
      it "should work as expected" do
        i = @human.new name: :Fred
        @ns.instances.size.must_equal 1
        @ns.__forget__( :Fred ).must_equal false
        @ns.instances.size.must_equal 1
        @ns.__forget__( i ).must_equal :Fred
        @ns.instances.size.must_equal 0
      end
    end

    describe "Namespace#forget_nameless_instances" do
      it "should work as expected" do
        i = @saint.new ɴ: "Dave"
        j = @saint.new
        @ns.instances.size.must_equal 2
        @ns.forget_nameless_instances
        @ns.instances.must_equal [ i ]
      end
    end

    describe "Namespace#forget_all_instances" do
      it "should work as expected" do
        @saint.new ɴ: "Dave"
        @ns.instances.size.must_equal 1
        @ns.forget_all_instances
        @ns.instances.must_equal []
      end
    end

    describe "Namespace#instantiation_exec hook" do
      it "should work as expected" do
        flag = false
        @ns.instantiation_exec do flag = true end
        @saint.new
        assert flag
      end
    end

    describe "Namespace#exec_when_naming hook" do
      it "should work as expected" do
        flag = false
        @ns.exec_when_naming do |name, _, _| flag = true; name end
        @saint.new
        refute flag
        @ns.instances.first.name = :Dave
        assert flag
      end
    end

    describe "Namespace#validate_name" do
      it "should work as expected" do
        @ns.validate_name( :Dave ).must_equal "Dave"
      end
    end
  end # describe NameMagic::Namespace

  describe "instance methods" do
    describe "#_name_" do
      it "should return demodulized name of the instance" do
        skip
        flunk "Tests not written!"
      end
    end

    describe "#full_name" do
      it "should return full name of the instance" do
        skip
        flunk "Tests not written!"
      end
    end

    describe "#__name__" do
      it "returns full name without triggering #const_magic" do
        skip
        flunk "Tests not written!"
      end
    end

    describe "#name=" do
      it "names the instance" do
        skip
        flunk "Tests not written!"
      end
    end

    describe "#name!" do
      it "names the instance aggresively" do
        skip
        flunk "Tests not written!"
      end
    end

    describe "#avid?" do
      it "informes whether the instance is avid" do
        # Avid instance is an unnamed instance that is willing
        # to accept name even if this already belongs to another
        # instance, unregistering the conflicter in the process.
        # FIXME: Consider making all of this avid stuff private
        # to NameMagic, it only confuses the users.
      end
    end

    describe "#make_not_avid!" do
      it "removes the avid state of the instance" do
        # FIXME: Consider making all of this avid stuff private
        # to NameMagic, it only confuses the users.
        skip
        flunk "Tests not written!"
      end
    end

    describe "NameMagic#exec_when_named hook" do
      it "is called upon instance naming" do
        c = @c.call
        i = c.new
        counter = 0
        i.exec_when_named do counter += 1 end
        counter.must_equal 0
        i.name = :Fred
        counter.must_equal 1
        j = c.new
        counter.must_equal 1
        c.class_exec do
          define_method :exec_when_named do
            -> name { counter += 1 } 
          end
        end
        j.name = :Joe
        counter.must_equal 2
        c.new name: "Dave"
        counter.must_equal 3
        # Finally, one more way how to use this hook.
        x = @c.call
        counter = 0
        x.instantiation_exec do |instance|
          instance.exec_when_named do |name|
            counter += 1
          end
        end
        x.new name: :St_IGNUcius
        counter.must_equal 1
      end

      describe "NameMagic#to_s" do
        it "is defined to show names of named instances" do
          skip
          flunk "Tests not written!"
        end
      end

      describe "NameMagic#inspect" do
        it "..." do
          # FIXME: It is not even clear it is needed.
          skip
          flunk "Tests not written!"
        end
      end
    end
  end # describe "NameMagic instance methods"

  describe NameMagic::ArrayMethods do
    before do
      c = @c.call
      @e1 = c.new name: :Fred
      @e2 = c.new name: :Joe
      @e3 = c.new
      @e4 = c.new name: :Julia
      @a = @e1, @e2, @e3, @e4
    end

    describe "Array#names" do
      it "maps unnamed objects into nil by default" do
        @a.names.must_equal [ :Fred, :Joe, nil, :Julia ]
        @a.names( nil ).must_equal [ :Fred, :Joe, nil, :Julia ]
      end

      it "maps unnamed objects into themselves if option=true" do
        @a.names( true ).must_equal [ :Fred, :Joe, @e3, :Julia ]
      end

      it "omits the unnamed instances if option=false" do
        @a.names( false ).must_equal [ :Fred, :Joe, :Julia ]
      end
    end

    describe "Array#_names_" do
      it "maps unnamed objects into nil by default" do
        @a._names_.must_equal [ :Fred, :Joe, nil, :Julia ]
        @a._names_( nil ).must_equal [ :Fred, :Joe, nil, :Julia ]
      end

      it "maps unnamed objects into themselves if option=true" do
        @a._names_( true ).must_equal [ :Fred, :Joe, @e3, :Julia ]
      end

      it "omits the unnamed instances if option=false" do
        @a._names_( false ).must_equal [ :Fred, :Joe, :Julia ]
      end
    end
  end

  describe NameMagic::HashMethods do
    before do
      c = @c.call
      @i, @j = c.new( name: :Fred ), c.new( name: :Joe )
    end

    describe "Hash#keys_to_names" do
      # FIXME: Change this method to keys_to_full_names.
      it "must work as expected" do
        { @i => 1, @j => 2 }.keys_to_names
          .must_equal( { Fred: 1, Joe: 2 } )
      end
    end

    describe "Hash#keys_to_names!" do
      # FIXME: Change this method to keys_to_full_names!.
      it "must work as expected" do
        skip
        h = { @i => 1, @j => 2 }
        h.keys_to_names!
        h.must_equal( { Fred: 1, Joe: 2 } )
      end
    end

    describe "Hash#keys_to_ɴ" do
      it "must work as expected" do
        skip
        { @i => 1, @j => 2 }.keys_to_ɴ
          .must_equal( { Fred: 1, Joe: 2 } )
      end
    end

    describe "Hash#keys_to_ɴ!" do
      it "must work as expected" do
        skip
        h = { @i => 1, @j => 2 }
        h.keys_to_ɴ!
        h.must_equal( { Fred: 1, Joe: 2 } )
      end
    end
  end

  describe "renaming" do
    before do
      @human = @c.call
      @city = Module.new
      @human.namespace = @city
    end

    it "is possible without restrictions" do
      a = @human.new name: :Fred
      a.name.must_equal :Fred
      # Fred can be renamed to Joe without problems.
      a.name = :Joe
      a.name.must_equal :Joe
    end

    it "can be prohibited eg. by naming hook" do
      @city.exec_when_naming do |name, instance, old_name|
        fail NameError, "Renaming is now prohibited!" if old_name
        name
      end
      a = @human.new name: :Fred
      -> { a.name = :Joe }.must_raise NameError
    end
  end

  describe "name collisions" do
    before do
      @human = @c.call
      @city = Module.new
      @human.namespace = @city
      @a = @human.new name: :Fred
    end

    it "cannot construct another Fred by #new method" do
      -> { @human.new name: :Fred }.must_raise NameError
    end

    it "cannot construct another Fred by #name= method" do
      b = @human.new
      -> { b.name = :Fred }.must_raise NameError
    end

    it "can, however, steal name Fred by constant assignment" do
      m = Module.new
      m::Fred = @human.new
    end
  end

  describe "how avid instances work" do
  end

  describe "how NameMagic can be included modules and classes" do
    # This mainly tests NameMagic.included hook.
  end
end # describe NameMagic
