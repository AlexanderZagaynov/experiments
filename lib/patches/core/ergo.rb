module Kernel

  def ergo *args
    args.flatten!

    if block_given?
      (block = Proc.new).arity.one? ? yield(self) : instance_eval(&block)
    else
      args.empty? ? self : args.one? ? args.first : args
    end
  end

end
