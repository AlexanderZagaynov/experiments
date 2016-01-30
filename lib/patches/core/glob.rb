module Patches::Glob
  extend Patches

  def glob *args
    self.class.glob to_path, args
  end

  class_methods do

    def glob *args
      args.flatten!
      args, parts = args.partition { |arg| arg.is_a? Numeric }
      super File.join(*parts), *args
    end

  end

end

%i(Dir Pathname).each do |name|
  base = Object.const_defined?(name) ? Object.const_get(name) : Object.const_set(name, Class.new)
  base.include Patches::Glob
end
