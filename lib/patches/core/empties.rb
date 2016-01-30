module Patches::Empties
  extend Patches

  class_methods do
    def zero
      @zero ||= new.freeze
    end
  end

  def zero?
    self == self.class.zero
  end
end

[String, Array, Hash].each { |base| base.include Patches::Empties }
