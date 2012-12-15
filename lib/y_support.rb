#encoding: utf-8
require "y_support/version"

require 'mathn'
require 'set'
require 'csv'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/duplicable'
require 'active_support/core_ext/string/starts_ends_with'
require 'active_support/core_ext/string/strip'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/integer/multiple'
require 'active_support/core_ext/integer/inflections'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/conversions' # such as #to_xml
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/diff'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/hash/indifferent_access'

module YSupport
  USE_SCRUPLE = true
end
