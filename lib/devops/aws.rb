require 'awesome_print'
AwesomePrint.defaults = { indent: -2 }


# require 'nokogiri'
# require 'open-uri'

# page = open 'http://docs.aws.amazon.com/general/latest/gr/rande.html'
# sections = Nokogiri::HTML(page).css('div#rande div.section')

# sections.each do |section|
#   section_id = section.css('div.titlepage h2.title') #[id$=region]')
#   # ap section_id unless section_id.empty?
#   next unless section_id.empty?
#   text = []
#   section.traverse { |node| text << node.text if node.text? }
#   puts text.join("\n")
#   puts '', '---', ''
# end if sections


require 'pathname'
require 'json'

require 'aws-sdk'
aws_gem_path = Pathname.new Gem.loaded_specs['aws-sdk-core'].full_gem_path
apidefs_path = aws_gem_path / 'apis'

Module.new do
  refine String do
    def to_usym
      Seahorse::Util.underscore(self).to_sym
    end
  end

  refine Array do

    def shift_while *args
      raise ArgumentError, 'Missing block' unless block_given?
      shift *args, do_while: true, &Proc.new
    end

    def shift *args, do_while: false #, do_unless: false
      if block_given?
        is_array = !args.empty?
        # do_while ||= !do_unless
        result = obj = nil
        result = yield obj while (obj = super *args) &&
          !(obj.empty? if is_array) && !(do_while && result)
        result if do_while
      else
        super *args
      end
    end

  end

  refine Hash do
    def dig! *keys
      result = self
      keys.each { |key| result = result.fetch key }
      result
    end
  end
end.tap { |mod| using mod }

escapes = [
  'Aws.add_service(:', ', {',
  '  api: "#{Aws::API_DIR}/', '/api-2.json', '",',
  '  resources: "#{Aws::API_DIR}/', '/resources-1.json', '",',
].map { |str| Regexp.escape str }

service_name_regexp = /^#{escapes.shift}(.*)#{escapes.shift}$/
api_location_regexp = /^#{escapes.shift}(.*#{escapes.shift})#{escapes.shift}$/
res_location_regexp = /^#{escapes.shift}(.*#{escapes.shift})#{escapes.shift}$/

services = {}

Pathname.glob aws_gem_path / 'lib' / 'aws-sdk-core' / '*.rb' do |source_file|
  lines = source_file.readlines

  service_name = service_name_regexp.match(lines.shift) { |m| m.captures.first }
  api_location = api_location_regexp.match(lines.shift) { |m| m.captures.first }
  next unless service_name && api_location

  methods_list = []

  api_data = JSON.parse (apidefs_path / api_location).read
  operations, shapes = api_data.values_at 'operations', 'shapes'

  if res_location = lines.shift_while { |l| res_location_regexp.match(l) { |m| m[1] } }
    resources_data = (JSON.parse (apidefs_path / res_location).read).dig('service', 'hasMany')
    resource_operations =
      resources_data.values.map { |resource_data| resource_data.dig! 'request', 'operation' }
    operations = operations.select { |key, value| resource_operations.include? key }
  end

  operations.each do |operation_name, operation|
    next unless output_members = shapes[operation.dig 'output', 'shape']&.fetch('members')

    input_shape   = shapes[operation.dig 'input',  'shape']
    input_members = input_shape&.[]('members')
    method_params = {}

    next if input_shape&.[]('required')&.any? do |member_name|
      member_shape = shapes.fetch input_members[member_name]['shape']

      method_params[member_name.to_usym] = case
      when member_name == 'Limit' # WAF
        member_shape['max']
      when member_name == 'MaxResults' # CognitoIdentity
        member_shape['max']
      when member_name == 'accountId' # Glacier
        '-'
      when variations = member_shape['enum']
        variations
      else
        next true
      end

      false
    end

    next if output_members.none? do |member_name, member|
      member_shape = shapes.fetch member.fetch 'shape'
      next true if member_shape['type'] == 'list'

      member_shape['members']&.any? do |member_name, member|
        member_shape = shapes.fetch member.fetch 'shape'
        member_shape['type'] == 'list'
      end
    end

    method_data = operation_name.to_usym
    method_data = [method_data, method_params] unless method_params.empty?

    methods_list << method_data
  end

  services[service_name] = methods_list unless methods_list.empty?
end

ap services
