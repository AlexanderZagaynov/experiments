class Hash

  def natural!
    self.default = nil
    self.default_proc = nil
    self
  end

  def natural
    dup.natural!
  end

  # def of_hashes!
  #   self.natural!
  #   self.default_proc = self.class.of_hashes_block
  #   self.extend Of
  #   self
  # end

  # def of_hashes
  #   dup.of_hashes!
  # end

  module Of
    def delete key, &block
      self[key] unless has_key?(key) || block_given?
      super key, &block
    end
  end

  def self.of_arrays
    result = new &of_arrays_block
    result.extend Of
    result
  end

  def self.of_hashes
    result = new &of_hashes_block
    result.extend Of
    result
  end

  private

  def self.of_arrays_block
    @of_arrays_block ||= proc { |hash, key| hash[key] = [] }
  end

  def self.of_hashes_block
    @of_hashes_block ||= proc { |hash, key| hash[key] = of_hashes }
  end

end
