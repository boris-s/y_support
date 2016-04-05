# encoding: utf-8

module NameMagic::HashMethods
  # Maps the hash into one whose keys have been replaced with full
  # names of the keys (using #full_name method).
  # 
  def keys_to_names # FIXME: Change to #keys_to_full_names
    with_keys do |key| key.name || key end
    # FIXME: Change #name to #full_name
  end

  # Modifies a hash in place so that the keys are replaced with key
  # names (key objects are assumed to respond to +#name+ method).
  # 
  def keys_to_names! # FIXME: Change to #keys_to_full_names!
    with_keys! do |key| key.name || key end
    # FIXME: Change #name to #full_name
  end

  # Maps the hash into one whose keys have been replaced with
  # names of the key objects (using #_name_ method).
  # 
  def keys_to_ɴ
    with_keys do |key| key._name_ || key end
  end

  # Modifies a hash in place so that the keys are replaced with key
  # names (using +#_name_+ method).
  # 
  def keys_to_ɴ!
    with_keys! do |key| key._name_ || key end
  end
end
