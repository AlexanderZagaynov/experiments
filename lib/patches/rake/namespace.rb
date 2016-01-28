class Rake::NameSpace

  def retain arg_names, deps
    Rake::Patches::NameSpace.retain @task_manager, @scope.path, arg_names, deps
  end

end

class Rake::Patches::NameSpace
  NAMESPACE_SEPARATOR = ':'.freeze

  def self.retain task_manager, path, arg_names, deps
    deps = [deps] unless deps.respond_to?(:to_ary)
    return if arg_names.empty? && deps.empty?
    deps = deps.map { |d| Rake.from_pathname(d).to_s }
    storage(task_manager).retain path, arg_names, deps
  end

  def self.apply!
    data = nil
    data.pop.apply! while data = storages.shift
  end

  %i(task_manager storage).tap do |names|
    attr_reader *names
    private     *names
  end

  def initialize task_manager
    @task_manager = task_manager
    @storage      = Hash.new
  end

  def retain path, arg_names, deps
    (storage[path] ||= []) << [arg_names, deps]
  end

  def apply!
    data = nil
    apply *data while data = storage.shift
    create_outers!
  end

  private

  def apply path, params
    scope = OpenStruct.new path: path

    while data = params.pop
      arg_names, deps = data

      task_manager.tasks_in_scope(scope).each do |task|
        task.instance_variable_set :@prerequisites, deps | task.prerequisites
        task.set_arg_names arg_names unless arg_names.empty?
      end
    end
  end

  def create_outers!
    tasks, names = task_manager.tasks
      .reject { |task| task.is_a? Rake::FileTask }
      .each_with_object [{}, {}] do |task, (tasks, names)|
        name = task.name
        tasks[name] = task

        next if (parts = name.split(NAMESPACE_SEPARATOR)[0..-2]).empty?
        next if names.has_key? name = parts.join(NAMESPACE_SEPARATOR)

        names[name] = [name, parts.last].join(NAMESPACE_SEPARATOR)
      end

    names.each do |ext_name, int_name|
      next if tasks.has_key?(ext_name) || !tasks.has_key?(int_name)
      task = Rake::Task.define_task ext_name => int_name

      if Rake::TaskManager.record_task_metadata && tasks[int_name].comment
        task.add_description "Same as '#{int_name}'"
      end
    end
  end

  def self.storages
    @storages ||= Hash.new
  end

  def self.storage task_manager
    storages[task_manager] ||= new task_manager
  end
end
