module Rbs
  module Src
    class CommandRunner
      attr_reader :stdout

      def initialize(stdout:)
        @stdout = stdout
        @level = 0
      end

      def puts(message)
        prefix = "  " * @level
        stdout.puts "#{prefix}#{message}"
      end

      def push(message)
        puts "⏩️ #{message}"
        begin
          @level += 1
          yield
        ensure
          @level -= 1
        end
      end

      def execute!(*command, chdir: Pathname.pwd)
        # @type var out: String
        # @type var status: Process::Status

        out, status = Open3.capture2e(*command, chdir: chdir)

        unless status.success?
          puts "🚨 Command failed: #{command.inspect} in #{chdir}..."
          out.each_line do |line|
            puts "| #{line}"
          end
          raise status.inspect
        end
      end
    end
  end
end
