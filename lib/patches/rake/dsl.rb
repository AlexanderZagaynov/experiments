module Rake::Patches::DSL

  def namespace *args, &block
    name, arg_names, deps = Rake.application.resolve_args args
    super(name, &block).tap { |ns| ns.retain arg_names, deps }
  end

  def hide name
    task_name = Rake.application.current_scope.path_with_task_name name
    if Rake::TaskManager.record_task_metadata && Rake::Task.task_defined?(task_name)
      Rake::Task[task_name].clear_comments
    end
  end

end

Rake::DSL.prepend Rake::Patches::DSL
extend Rake::Patches::DSL
