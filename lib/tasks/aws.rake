namespace aws: :setup do

  task aws: :list

  task :setup do
    require 'awesome_print'
    AwesomePrint.defaults = { indent: -2 }

    def client
      @client ||= Aws::CloudFormation::Client.new
    end

    def configs
      unless defined? @configs
        @configs = {}
        base = Pathname.new(__dir__) / '..' / 'devops' / 'aws'

        base.glob('**', "*{#{File::SEPARATOR},.yml}").each do |path|

          parts = path.relative_path_from(base).each_filename.to_a
          parts.pop if path.file?

          branch = @configs
          parts.each { |part| branch = branch[part] ||= Hash.new }

          next unless path.file?
          filename = path.to_path

          erb = ERB.new path.read # 'r:bom|utf-8'
          erb.filename = filename

          config = YAML.load erb.result, filename
          (branch[path.barename.to_path] ||= {})[:shared] = config if config

        end
        # @configs.keys.sort.each { |k| @configs[k] = @configs.delete(k) }
      end
      @configs
    end
    ap configs
  end

  desc 'List AWS stacks'
  task :list do
    ap client.list_stacks
  end

  desc 'Describe AWS stacks'
  task :describe do
    ap client.describe_stacks
  end

  desc 'Create / Update AWS stacks'
  task :apply do

    # stacks = {}
    # stacks_path = File.join data_path, 'stacks.yml'
    # stacks.merge! YAML.load_file stacks_path if File.file? stacks_path

    # files = Dir.glob File.join data_path, 'stacks', '*.yml'
    # files.each do |file|
    #   next unless File.file? file

    #   name = File.barename file
    #   old_value = stacks[name]
    #   new_value = YAML.load_file(file) || {}

    #   case old_value
    #   when NilClass
    #     stacks[name] = new_value
    #   when Array, Set
    #     stacks[name] = old_value + new_value
    #   when Hash
    #     case new_value
    #     when Hash
    #       old_value.merge! new_value
    #     when Array
    #       stacks[name] = new_value << old_value
    #     else
    #       fail
    #     end
    #   else
    #     fail
    #   end
    # end

    # stacks.each do |stack_name, stack|
    #   stack[:stack_name] = stack_name

    #   ap stack
    #   ap client.create_stack stack
    # end

  end
end
