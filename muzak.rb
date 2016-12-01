require "muzak"
require "readline"
require "shellwords"

opts = {
  debug: ARGV.include?("--debug") || ARGV.include?("-d"),
  verbose: ARGV.include?("--verbose") || ARGV.include?("-v"),
  batch: ARGV.include?("--batch") || ARGV.include?("-b")
}

Thread.abort_on_exception = opts[:debug]

muzak = Muzak::Instance.new(opts)

COMMANDS = Muzak::Cmd.humanize_commands!

CONFIG_REGEX = /^config-(get)|(set)|(del)/
ARTIST_REGEX = Regexp.union COMMANDS.select{ |c| c =~ /artist/ }.map { |c| /^#{c}/ }
ALBUM_REGEX = Regexp.union COMMANDS.select{ |c| c =~ /album/ }.map { |c| /^#{c}/ }

comp = proc do |s|
  case Readline.line_buffer
  when CONFIG_REGEX
    muzak.config.keys.grep(Regexp.new(Regexp.escape(s)))
  when ARTIST_REGEX
    ss = Readline.line_buffer.split(" ")
    muzak.index.artists.grep(Regexp.new(Regexp.escape(ss[1..-1].join(" "))))
  when ALBUM_REGEX
    muzak.index.album_names.grep(Regexp.new(Regexp.escape(s)))
  else
    COMMANDS.grep(Regexp.new(Regexp.escape(s)))
  end
end

Readline.completion_append_character = " "
Readline.completion_proc = comp

while line = Readline.readline("muzak> ", true)
  cmd_argv = Shellwords.split(line)
  next if cmd_argv.empty?
  muzak.send Muzak::Cmd.resolve_command(cmd_argv.shift), *cmd_argv
end
