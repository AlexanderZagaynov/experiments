class Module
  prepend begin
    Module.new do

      def prepend *args
        args << Module.new(&Proc.new) if block_given?
        super *args unless args.empty?
      end

      def include *args
        args << Module.new(&Proc.new) if block_given?
        super *args unless args.empty?
      end

      def extend *args
        args << Module.new(&Proc.new) if block_given?
        super *args unless args.empty?
      end

    end
  end
end
