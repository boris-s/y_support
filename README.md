# YSupport

`YSupport` is a common support library for Y* gems (`y_petri`, `yzz`,
`y_nelson`, `sy`...). At the moment, it is a collection of all and sundry
helpful methods, which can be divided as follows

  * `NameMagic` (`lib/name_magic.rb`) -- its main feature is that it allows
    constant magic known from classes to work with any objects.
  * Miscellaneous helpful methods (`lib/misc.rb`)
  * Typing (runtime assertions, `lib/typing.rb`)
  * Other smaller components:
    - `unicode.rb` -- shortcut letter for class (ç), singleton class (ⓒ) etc.
    - `null_object.rb`
    - `try.rb` -- a different kind of `#try` method
    - several other small fry components

## NameMagic

Try for example:
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
  unnamed_kitten = Cat.new
```
Mixin `NameMagic` makes class `Animal` keep registry of its instances:
```ruby
  Animal.instances.names
  #=> [:Pochi, nil]
  Tama = unnamed_kitten
  Animal.instances.names
  #=> [:Pochi, :Tama]
  Cheburashka = Animal.new
  Animal.instances.names
  #=> [:Pochi, :Tama, :Cheburashka]
  Dog.instances.names
  #=> [:Pochi]
  Animal.instances.each &:speak
  Dog.instances.each &:speak
  Cat.instances.each &:speak
```

## Other components

Read the documentation of the individual methods.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
