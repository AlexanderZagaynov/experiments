module Rake::Patches::DSL

  def namespace *args, &block
    name, arg_names, deps = Rake.application.resolve_args args
    super(name, &block).tap { |ns| ns.retain arg_names, deps }
  # rescue => e
  #   e = e.exception 'Namespace Argument Error' if e.message == 'Task Argument Error'
  #   raise e
  end

end

# ObjectSpace.each_object(Rake::DSL) { |object| object.extend Rake::Patches::DSL }
Rake::DSL.prepend Rake::Patches::DSL
extend Rake::Patches::DSL
