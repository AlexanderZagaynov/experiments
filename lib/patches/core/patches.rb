module Kernel
  def require_patches patches_path
    require_relative "../#{patches_path}"
  end
end
