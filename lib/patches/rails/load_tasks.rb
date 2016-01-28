class Rails::Application
  prepend do
    # using Refinements::RequireHooks

    def load_tasks(*)
      # after_require('rake') { require_patches 'rake' }
      require_patches 'rake'
      super
    end
  end
end
