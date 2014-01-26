# encoding: utf-8

class Hash
  # Maps the hash into one whose keys have been replaced with full names of
  # the keys (which are assumed to be objects responding to +#full_name+ method).
  # 
  def keys_to_names                        # FIXME: Change to keys_to_full_names
    with_keys do |key| key.name || key end # FIXME: Change name to full_name
  end

  # Modifies a hash in place so that the keys are replaced with key names (key
  # objects are assumed to respond to +#name+ method).
  # 
  def keys_to_names!                        # FIXME: Change to keys_to_full_names!
    with_keys! do |key| key.name || key end # FIXME: Change name to full_name
  end

  # Maps a hash into a hash, whose keys have been replaced with names of the
  # key objects (which are assumed to respond to +#name+ method).
  # 
  def keys_to_ɴs
    with_keys do |key| key._name_ || key end
  end

  # Modifies a hash in place so that the keys are replaced with key names (key
  # objects are assumed to respond to +#name+ method).
  # 
  def keys_to_ɴs!
    with_keys! do |key| key._name_ || key end
  end
end
