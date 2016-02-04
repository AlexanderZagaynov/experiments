namespace aws: :initialize do
  task aws: :describe

  task :initialize do
    require 'awesome_print'
    AwesomePrint.defaults = { indent: -2 }

    private

    def client
      @client ||= Aws::CloudFormation::Client.new
    end

    def existing
      @existing ||= describe_stacks[:stacks].map(&:stack_name)
    end

    def list_stacks
      @list_stacks ||= client.list_stacks
    end

    def describe_stacks
      @describe_stacks ||= client.describe_stacks
    end

    def stack
      unless defined? @stack
        resources = configs.delete!(:resources)

        instances = configs.delete!(:instances)
        instances.each do |name, instance|

          properties = instance.delete!(:properties)
          properties['ImageId'] = instance.delete!(:image)

          instance['Type'] = 'AWS::EC2::Instance'
          instance['Properties'] = properties

          resources[name] = instance

        end

        template = configs.delete!(:template)
        template['Description'] = template.delete!(:description)
        template['Resources']   = resources

        stack = configs.delete!(:stack)
        stack[:stack_name] = stack.delete!(:name)
        stack[:template_body] = template.to_json

        @stack = stack.natural!
      end
      @stack
    end

    def configs
      unless defined? @configs
        configs = ActiveSupport::HashWithIndifferentAccess.of_hashes

        base = Pathname.new(__dir__) / '..' / 'devops' / 'aws'
        Pathname.glob(base / '**' / '*.yml').each do |path|

          filename = path.to_path
          erb = ERB.new path.read mode: 'r:bom|utf-8'
          erb.filename = filename
          config = YAML.load erb.result, filename
          next unless config

          parts  = path.relative_path_from(base).each_filename.to_a[0..-2]
          branch = parts.inject(configs) { |branch, part| branch[part] }
          branch[path.barename.to_path] = config

        end
        @configs = configs.of_hashes!
      end
      @configs
    end

    # ap configs
    # ap stack
  end

  desc 'List AWS stacks'
  task :list do
    ap list_stacks
  end

  desc 'Describe AWS stacks'
  task :describe do
    ap describe_stacks
  end

  desc 'Validate AWS stack templates'
  task :validate do
    ap client.validate_template stack.slice :template_body
  end

  desc 'Create / Update AWS stacks'
  task :apply do
    result =
      if existing.include? stack[:stack_name]
        client.update_stack stack
      else
        client.create_stack stack
      end
    ap result
  end

  desc 'Delete AWS stacks'
  task :delete do
    ap client.delete_stack stack.slice :stack_name
  end
end
