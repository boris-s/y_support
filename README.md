# YSupport

`YSupport` is a common support library for Y* gems (`y_petri`, `yzz`,
`y_nelson`, `sy`...). At the moment, it is a collection of all and sundry
helpful methods, which can be divided as follows

  * `NameMagic` (`lib/name_magic.rb`) -- its main feature is that it allows
    constant magic so well known from Ruby classes (`Foo = Class.new;
    Foo.name #=> "Foo"`) to work with any objects.
  * Miscellaneous helpful methods (`lib/misc.rb`)
  * Typing (runtime assertions, `lib/typing.rb`)
  * Other smaller components:
    - `unicode.rb` -- shortcut letter for class (ç), singleton class (ⓒ) etc.
    - `null_object.rb`
    - `try.rb` -- a different kind of `#try` method
    - several other small fry components

## NameMagic

Ruby classes are well known for their "constant magic": When they are assigned
to constants, they acquire `name` attribute corresponding to the constant name.
```ruby
  x = Class.new
  x.name #=> nil
  Foo = x
  x.name #=> "Foo"
```
NameMagic mixin lends this feature to any Ruby class. The class in which
NameMagic is mixed in will also hold the registry of the instances, named or
unnamed. Example code:
```ruby
  require 'y_support/name_magic'

  class Animal
    include NameMagic
    def sound; "squeak" end
    def speak; 2.times { puts sound.capitalize << ?! } end
  end

  class Dog < Animal; def sound; "bark" end end
  class Cat < Animal; def sound; "meow" end end

  Pochi = Dog.new
  anonymous_kitten = Cat.new
```
Mixin `NameMagic` makes class `Animal` keep registry of its instances:
```ruby
  Animal.instances.names
  #=> [:Pochi, nil]
  Tama = anonymous_kitten
  Animal.instances.names
  #=> [:Pochi, :Tama]
  # Name can also be supplied to the constructor explicitly:
  Animal.new name: :Cheburashka
  Animal.instance( "Cheburashka" )
  Animal.instance( "Cheburashka" ).name
  :Cheburashka
  Animal.instances.names
  #=> [:Pochi, :Tama, :Cheburashka]
  Dog.instances.names
  #=> [:Pochi]
  Animal.instances.each &:speak
  Dog.instances.each &:speak
  Cat.instances.each &:speak
```
The registry of instances is maintained by the namespace, so the instances can
only be garbage collected after the namespace is garbage collected. If the user
wants to enable this earlier, the namespace can be ordered to forget them:
```ruby
  Animal.forget_all_instances
  Animal.instances
  []
```

## Other components

Read the documentation of the individual methods.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
