module Rake::Patches::Application

  def top_level
    Rake::Patches::NameSpace.apply!
    super
  end

end

Rake::Application.prepend Rake::Patches::Application
