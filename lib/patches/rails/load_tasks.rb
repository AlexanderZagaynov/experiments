class Rails::Application
  prepend do

    def load_tasks(*)
      require_patches 'rake'
      super
    end
  end
end
