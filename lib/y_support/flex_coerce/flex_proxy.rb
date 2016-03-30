# coding: utf-8

# In FlexCoerce, #coerce method of the host class is made to return a pair
# [ proxy, receiver ], where proxy is an object of FlexProxy class. As name
# suggests, proxy represents and wraps argument that has been supplied to
# #coerce method. This gives the user the opportunity to teach the proxy to
# correctly respond to various operators (#+, #-, #*, #/,...) and other
# methods. Instances of FlexProxy are essentially a single-use objects –
# they respond to a single message, after which their life should end.
# 
class FlexCoerce::FlexProxy
  class << self
    alias of new # allows statements such as FlexProxy.of( first_operand )
  end
    
  attr_reader :operand

  # Method #host_class is delegated to self.class. It refers to the
  # host class to which a parametrized subclass of FlexProxy belongs.
  # 
  def host_class
    self.class.host_class
  end
    
  # The constructor of FlexProxy requires only one parameter: The first operand
  # which has been supplied to #coerce method.
  # 
  def initialize first_operand
    @operand = first_operand
  end

  # Proxy is essentially a single-use object. In its life, it receives a single
  # message and returning the result. Unless the user specifically orders
  # FlexProxy to respond to a method, it should raise TypeError.
  # 
  def method_missing ß, arg
    table_entry = host_class.coercion_table[ ß ]
    response = table_entry.find { |type, closure| type === operand }
    fail TypeError arg, "#{operand.class} not compatible with " +
                        "#{arg.class} and ##{ß} method!" unless response
    response[ 1 ].call( operand, arg )
  end

  # Basic form of Proxy#+ method simply raises TypeError. The user is expected
  # to override this method as necessary.
  # 
  def + arg
    table_entry = host_class.coercion_table[ :+ ]
    response = table_entry.find { |type, closure| type === operand } or
      fail TypeError, "#{arg.class} cannot be added to a #{operand.class}!"
    response[ 1 ].call( operand, arg )
  end

  # Basic form of Proxy#- method simply raises TypeError. The user is expected
  # to override this method as necessary.
  # 
  def - arg
    table_entry = host_class.coercion_table[ :- ]
    response = table_entry.find { |type, closure| type === operand } or
      fail TypeError, "#{arg.class} cannot be subtracted " +
                      "from a #{operand.class}!"
    response[ 1 ].call( operand, arg )
  end

  # Basic form of Proxy#* method simply raises TypeError. The user is expected
  # to override this method as necessary.
  # 
  def * arg
    table_entry = host_class.coercion_table[ :* ]
    response = table_entry.find { |type, closure| type === operand } or
      fail TypeError, "#{operand.class} cannot be multiplied " +
                      "by a #{arg.class}!"
    response[ 1 ].call( operand, arg )
  end

  # Basic form of Proxy#/ method simply raises TypeError. The user is expected
  # to override this method as necessary.
  # 
  def / arg
    table_entry = host_class.coercion_table[ :/ ]
    response = table_entry.find { |type, closure| type === operand } or
      fail TypeError, "#{arg.class} cannot be divided by a #{operand.class}!"
    response[ 1 ].call( operand, arg )
  end

  # Basic form of Proxy#** method simply raises TypeError. The user is expected
  # to override this method as necessary.
  # 
  def ** arg
    table_entry = host_class.coercion_table[ :** ]
    response = table_entry.find { |type, closure| type === operand } or
      fail TypeError, "#{arg.class} cannot be raised to a #{operand.class}!"
    response[ 1 ].call( operand, arg )
  end

  # For less common operators, methods raising TypeError are defined below.
  # Again, the user is expected to override them whenever necessary.
  # 
  [ :%,
    :div,
    :divmod,
    :fdiv,
    :&,
    :|,
    :^,
    :>,
    :>=,
    :<,
    :<=,
    :<=>,
    :=== # Operator === is mostly too liberal to call coerce.
  ].each do |binary_operator|
    define_method binary_operator do |arg|
      table_entry = host_class.coercion_table[ binary_operator ]
      response = table_entry.find { |type, closure| type === operand } or
        fail TypeError, "#{arg.class} is not compatible with #{operand.class} " +
                        "and binary operator ##{binary_operator}"
      response[ 1 ].call( operand, arg )
    end
  end
end # class FlexCoerce::FlexProxy
