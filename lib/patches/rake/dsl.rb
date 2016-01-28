module Rake::Patches::DSL

  def namespace *args, &block
    name, arg_names, deps = Rake.application.resolve_args args
    super(name, &block).tap { |ns| ns.retain arg_names, deps }
  # rescue => e
  #   e = e.exception 'Namespace Argument Error' if e.message == 'Task Argument Error'
  #   raise e
  end

  def hide name
    task_name = Rake.application.current_scope.path_with_task_name name
    if Rake::TaskManager.record_task_metadata && Rake::Task.task_defined?(task_name)
      Rake::Task[task_name].clear_comments
    end
  end

end

# ObjectSpace.each_object(Rake::DSL) { |object| object.extend Rake::Patches::DSL }
Rake::DSL.prepend Rake::Patches::DSL
extend Rake::Patches::DSL
