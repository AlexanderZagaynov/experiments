module Empties

  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods

    def zero
      @zero ||= new.freeze
    end

  end

  def zero?
    self == self.class.zero
  end

end

[String, Array, Hash].each { |base| base.include Empties }
