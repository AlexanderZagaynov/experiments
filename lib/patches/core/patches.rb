module Kernel

  def require_patches patches_path
    require_relative "../#{patches_path}"
  end

  module Patches
    refine Object do
      def require_patch patch_name
        patches_base = File.basename caller_locations(1..1).first.path, '.*'
        require_patches "#{patches_base}/#{patch_name}"
      end
    end
  end

end
