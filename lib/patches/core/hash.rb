class Hash
  OF_HASHES_PROC = proc { |hash, key| hash[key] = hash.class.of_hashes }

  def self.of_hashes
    new &OF_HASHES_PROC
  end

  def natural!
    self.default = nil
    self.default_proc = nil
    each_value { |value| value.natural! if Hash === value }
    self
  end

  def of_hashes!
    self.default = nil
    self.default_proc = OF_HASHES_PROC
    each_value { |value| value.of_hashes! if Hash === value }
    self
  end

  def of_hashes?
    default_proc == OF_HASHES_PROC
  end

  def delete! key, &block
    if has_key?(key) || block_given? || !of_hashes?
      delete key, &block
    else
      self.class.of_hashes
    end
  end
end
