require "muzak"
require "shellwords"

opts = {
  debug: ARGV.include?("--debug") || ARGV.include?("-d"),
  verbose: ARGV.include?("--verbose") || ARGV.include?("-v"),
  batch: ARGV.include?("--batch") || ARGV.include?("-b")
}

Process.daemon

Thread.abort_on_exception = opts[:debug]

muzak = Muzak::Instance.new(opts)

fifo_path = File.join(Muzak::CONFIG_DIR, "muzak.fifo")
File.mkfifo(fifo_path)

File.open(fifo_path, "r") do |fifo|
  loop do
    cmd_argv = Shellwords.split(fifo.readline) rescue next
    next if cmd_argv.empty? || cmd_argv.any?(&:empty?)
    muzak.send Muzak::Cmd.resolve_command(cmd_argv.shift), *cmd_argv
  end
end

# there is definitely a cleaner way to do this.
at_exit do
  File.delete(fifo_path) if File.exist?(fifo_path)
end