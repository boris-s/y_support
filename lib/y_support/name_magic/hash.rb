# encoding: utf-8

class Hash
  # Maps a hash into a hash, whose keys have been replaced with names of the
  # key objects (which are assumed to respond to +#name+ method).
  # 
  def keys_to_names
    with_keys do |key| key.name || key end
  end

  # Modifies a hash in place so that the keys are replaced with key names (key
  # objects are assumed to respond to +#name+ method).
  # 
  def keys_to_names!
    with_keys! do |key| key.name || key end
  end
end
