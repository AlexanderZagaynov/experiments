require 'erb'
require 'yaml'
require 'pathname'

module ConfigTree
  def self.load path
    ConfigTree::Loader.new(path).tree
  end
end

module ConfigTree::Patches
  private

  (%w[public protected private].product %w[reader writer accessor]).each do |combination|
    scope, kind = combination
    module_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{scope}_attr_#{kind} *attrs
        attrs.flatten!
        attr_#{kind} *attrs
        #{scope} *attrs
      end
      alias_method :#{scope}_attr_#{kind}s, :#{scope}_attr_#{kind}
    RUBY
  end

  # def const_reader const_name, method_name = nil
  #   method_name ||= const_name.to_s.downcase
  #   singleton_class.define_method(method_name) { const_get const_name, false }
  #   define_method(method_name) { self.class.send method_name }
  # end

  # def const_readers *args
  #   args.flatten!
  #   args.map { |const_name| const_reader const_name }
  # end
end

class ConfigTree::Node
  extend ConfigTree::Patches

  EMPTY_NODE = new.freeze

  public_attr_reader  :value
  private_attr_reader :nodes

  def initialize
    @nodes = Hash.new
    @value = nil
  end

  def add data, route = nil
    get_node(route).set_data(data)
  end

  def freeze
    nodes.each_value(&:freeze)
    value.freeze
    super
  end

  def [] name
    nodes.fetch(name.to_s) { |name| frozen? ? EMPTY_NODE : nodes[name] = self.class.new }
  end

  def to_h
    {
      value: (value.is_a?(ConfigTree::Node) ? value.to_h : value),
      nodes: nodes.each_with_object({}) { |(name, node), memo| memo[name] = node.to_h },
    }
  end

  protected

  def set_data data
    raise 'Node is frozen' if frozen?
    raise 'Data exists' if value

    if data.respond_to? :each_pair
      node = @value = self.class.new
      data.each_pair { |key, value| node.add value, key }
    else
      @value = data
    end
  end

  private

  def get_node route
    Array(route).inject(self) { |node, name| node[name] }
  end
end

class ConfigTree::Loader
  attr_reader :path

  def initialize path
    @path = Pathname.new path
    validate
  end

  def tree
    @tree ||= read_tree
  end

  private

  def validate
    unless path.file? && path.extname == '.yml' || path.directory?
      raise ArgumentError, 'Given path must point to a dir or to a file with yml extension'
    end
  end

  def read_tree
    tree = ConfigTree::Node.new

    if path.file?
      tree.add read_file path
    else
      Pathname.glob(path / '**' / '*.yml').each do |file|

        route = file.relative_path_from(path).each_filename.to_a
        route.push File.basename route.pop, '.*'
        tree.add read_file(file), route

      end
    end

    tree.freeze
  end

  def read_file name
    filename = name.to_path
    erb = ERB.new name.read mode: 'r:bom|utf-8'
    erb.filename = filename
    YAML.load erb.result, filename
  end
end
