namespace :aws do

  namespace :cloud do

    namespace :formation do

      namespace :stacks do

        desc 'List AWS CloudFormation Stacks'
        task :list do

          require 'awesome_print'

          client = Aws::CloudFormation::Client.new
          ap client.list_stacks

        end

        task :describe do
        end

      end

    end

  end

end
