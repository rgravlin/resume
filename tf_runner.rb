require 'sinatra'
require 'thin'
require 'utf8-cleaner'
require 'mixlib/shellout'

# Prevents UTF8 parsing errors
use UTF8Cleaner::Middleware

# Fixes Docker STDOUT logging
$stdout.sync = true

set :server, :thin
disable :show_exceptions, :raise_errors, :dump_errors

TF_BIN = "./terraform"
SHELL_TIMEOUT = ENV['CONFIG_SHELL_TIMEOUT'] || 600

ERRORS = {
  4000 => "Invalid request",
  4001 => "Invalid method",
  5000 => "Internal Server Error",
  5001 => "Command execution selection failure",
  5002 => "Command execution has no output",
  5003 => "Invalid Content-Length"
}

COMMANDS = {
  :init => "init -no-color",
  :plan => "plan -out=plan -no-color",
  :apply => "apply \"plan\" -no-color",
  :destroy => "destroy -auto-approve -no-color"
}

def error_check(error)
  ERRORS[error]
end

def run_it(verb, output=$stdout)

  cmd = Mixlib::ShellOut.new(
    [TF_BIN, COMMANDS[verb]].join(" "),
    :timeout => SHELL_TIMEOUT,
    :live_stdout => output,
    :live_stderr => output
  )

  begin
    cmd = cmd.run_command
  rescue Mixlib::ShellOut::CommandTimeout
    "Shell timed out.\nSTDERR: #{cmd.stderr}\nSTDOUT: #{cmd.stdout}"
  else
    halt 500, error_check(5002) if cmd.stdout.empty? && cmd.stderr.empty?
    if cmd.stderr.empty?
      cmd.stdout
    elsif cmd.stdout.empty?
      cmd.stderr
    else
      [cmd.stderr, cmd.stdout].join("\n")
    end
  end

end

before do
  method = request.request_method.to_s.upcase
  halt 405, error_check(4001) unless ["GET"].include?(method)
  halt 413, error_check(5003) if request.env["CONTENT_LENGTH"]
end

class HasRun
  @run = false
  @locked = false

  def self.retrieve
    @run
  end

  def self.submit(bit)
    @run = bit
  end

  def self.locked
    @locked = true
    @locked
  end

  def self.locked?
    @locked
  end
end

run_it(:init)
run_it(:plan)

get '/resume' do
  action = HasRun.retrieve ? "destroy" : "apply"

  stream do |out|
    case action
    when "apply"
      if HasRun.locked?
        run_it(:init, out)
        run_it(:plan, out)
        run_it(:apply, out)
      else
        run_it(:apply, out)
      end
    when "destroy"
      run_it(:destroy, out)
    else
      nil
    end
  end

  HasRun.retrieve ? HasRun.submit(false) : HasRun.submit(true)
  HasRun.locked

  response
end

get '/*' do
  halt 400, error_check(4005)
end

error do
  status 500
  body error_check(5000)
end
