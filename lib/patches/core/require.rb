module Refinements::RequireHooks

  refine Object do

    def before_require name, &block
      Refinements::RequireHooks.handle name, :before, block
    end

    def after_require name, &block
      Refinements::RequireHooks.handle name, :after, block
    end

  end

  private

  def self.storage
    @storage ||= Hash.new { |h, k| h[k] = { done: false, before: [], after: [] } }
  end

  def self.handle name, hook, block
    block ? add_block(name, hook, block) : run_blocks(name, hook)
  end

  def self.add_block name, hook, block
    raise ArgumentError, 'Missing block!' unless block
    raise RuntimeError, 'Already done!' if (data = storage[name])[:done] # $LOADED_FEATURES
    data[hook] << block
  end

  def self.run_blocks name, hook
    (data = storage[name])[:done] = true
    return if (blocks = data[hook]).zero?
    storage[hook] = Array.zero
    block = nil
    block.call while block = blocks.shift
  end

end

class Object
  using Refinements::RequireHooks

  def require name
    before_require name
    result = super
    after_require name
    result
  end
end
