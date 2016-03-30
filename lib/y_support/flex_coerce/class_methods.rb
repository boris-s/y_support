# coding: utf-8

# This module defines class methods, with which the host class of FlexProxy
# is to be extended.
# 
module FlexCoerce::ClassMethods
  # Class method .coercion_table provides access to the table of coercion
  # behavior specific to each host class. The table itself is a hash with
  # method names as keys. Each value is an array of pairs [ type, block ],
  # where type specifies the operand type, and block specifies the behavior
  # when the method in question is invoked with the given operand type.
  # 
  def coercion_table
    @coercion_table ||= Hash.new { |hash, missing_key|
      case missing_key
      when Symbol then hash[ missing_key ] = []
      else
        hash[ missing_key.to_sym ]
      end
    }
  end

  # Class method .define_coercion allows the classes that use FlexCoerce to
  # define custom coercion for certain symbols. The method expects: (1)
  # object type (or a list of object types), (2) +:method+ parameter
  # specifying the method(s) for which coercion is being defined, and (3) a
  # block that defines the operation. The block should take 2 ordered
  # arguments, representing first and second operand. The first operand is
  # the object that invoked #coerce method, the second operand is an
  # instance of the receiver class. Example:
  #
  # define_coercion Integer, method: :* do |operand1, operand2|
  #   operand2 * operand1 # swap the operands
  # end
  # 
  def define_coercion *types,
                      method: fail( ArgumentError, "When defining coercion, " +
                                   "method must be given!" ),
                      &block
    unless block.arity == 2
      fail ArgumentError, "The supplied block, which defines operation" +
                          "#{method}, must take exactly 2 arguments!"
    end
    # For each type, add one line to the coercion_table entry.
    types.each do |type|
      coercion_table[ method ] << [ type, block ]
    end
  end
end
