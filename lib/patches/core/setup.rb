module Refinements
end

module Patches

  def included base
    const(:ClassMethods).tap { |mod| base.singleton_class.prepend mod if mod }
  end

  def class_methods
    # raise ArgumentError, 'Missing block' unless block_given?
    const(:ClassMethods, create: true).tap { |mod| mod.module_eval &Proc.new }
  end

  private

  def const name, type: Module, create: false #, strict: false
    # result = const_defined?(name, false) && const_get(name)

    if const_defined? name, false

      result = const_get name
      unless result.is_a? type
        raise TypeError, "Constant #{name} is not a #{type.name}" if create # || strict
        result = nil
      end

    elsif create
      result = const_set name, type.send(:new)

    # elsif strict
    #   raise NameError, "Constant #{name} is not found in #{inspect}"

    end

    result
  end

end
