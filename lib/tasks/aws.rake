namespace aws: :initialize do
  task aws: :list

  task :initialize do
    require 'awesome_print'
    AwesomePrint.defaults = { indent: -2 }

    private

    def client
      @client ||= Aws::CloudFormation::Client.new
    end

    def list
      @list ||= client.list_stacks
    end

    def stacks
      unless defined? @stacks
        stacks = configs.delete('stacks')
        stacks.deep_merge! stacks.delete(:top)

        stacks.each do |name, stack|

          template = {}
          template.merge! stack.delete('template')
          template.merge! template.delete(:top) || {}

          resources = {}
          resources.merge! stack.delete('resources')
          resources.merge! resources.delete(:top) || {}

          instances = {}
          instances.merge! resources.delete('instances')

          instances.each do |name, instance|

            properties = instance['Properties'] ||= {}
            properties.merge! instance.delete(:top) || {}

            properties.natural!
            properties['ImageId'] ||= properties.delete('image')

            instance.natural!
            instance['Type'] = 'AWS::EC2::Instance'
            instance['Properties'] = properties

            resources[name] = instance
          end

          template['Resources'] = resources

          stack.natural!
          stack[:stack_name] ||= name
          stack[:template_body] = template.to_json

        end

        @stacks = stacks.natural!.values
      end
      @stacks
    end

    def configs
      unless defined? @configs
        configs = Hash.of_hashes

        base = Pathname.new(__dir__) / '..' / 'devops' / 'aws'
        base.glob('**', "*{#{File::SEPARATOR},.yml}").each do |path|

          parts = path.relative_path_from(base).each_filename.to_a
          parts.pop if path.file?

          branch = parts.empty? ? configs : configs.dig(*parts)

          next unless path.file?
          filename = path.to_path

          erb = ERB.new path.read # 'r:bom|utf-8'
          erb.filename = filename

          config = YAML.load erb.result, filename
          branch[path.barename.to_path][:top] = config if config

        end
        @configs = configs
      end
      @configs
    end

    # ap configs
    # ap stacks
  end

  desc 'List AWS stacks'
  task :list do
    ap list
  end

  desc 'Describe AWS stacks'
  task :describe do
    ap client.describe_stacks
  end

  desc 'Validate AWS stack templates'
  task :validate do
    stacks.each do |stack|
      ap client.validate_template stack.slice :template_body
    end
  end

  desc 'Create / Update AWS stacks'
  task :apply do
    existing = list[:stack_summaries].map { |stack| stack[:stack_name] }
    stacks.each do |stack|
      result =
        if existing.include? stack[:stack_name]
          client.update_stack stack
        else
          client.create_stack stack
        end
      ap result
    end
  end

  desc 'Delete AWS stacks'
  task :delete do
    stacks.each do |stack|
      ap client.delete_stack stack.slice :stack_name
    end
  end
end
