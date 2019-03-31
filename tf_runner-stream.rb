require 'bundler/setup'
require 'sinatra'
require 'thin'
require 'uri'
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

def valid_url?(uri)
  URI.parse(uri)
rescue URI::InvalidURIError
  halt 400, errcheck(4002)
end

def errcheck(err)
  errors = {
    4000 => "Invalid request",
    4001 => "Invalid method",
    5000 => "Internal Server Error",
    5001 => "Command execution selection failure",
    5002 => "Command execution has no output",
    5003 => "Invalid Content-Length"
  }

  errors[err]
end

def runit(verb, output=$stdout)

  commands = {
    "init" => "init -no-color",
    "plan" => "plan -out=plan -no-color",
    "apply" => "apply \"plan\" -no-color",
    "destroy" => "destroy -auto-approve -no-color"
  }

  cmd = [TF_BIN, commands[verb]].join(" ")
  cmd = Mixlib::ShellOut.new(cmd, :timeout => SHELL_TIMEOUT, :live_stdout => output, :live_stderr => output)

  begin
    cmd = cmd.run_command
  rescue Mixlib::ShellOut::CommandTimeout
    "Shell timed out.\nSTDERR: #{cmd.stderr}\nSTDOUT: #{cmd.stdout}"
  else
    halt 500, errcheck(5002) if cmd.stdout.empty? && cmd.stderr.empty?
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
  halt 405, errcheck(4001) unless ["GET"].include?(method)
  halt 413, errcheck(5003) if request.env["CONTENT_LENGTH"]
end

class HasRun
  @run = false
  @locked = false

  def self.get
    @run
  end

  def self.set(bit)
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

runit("init")
runit("plan")

get '/resume' do
  action = HasRun.get ? "destroy" : "apply"

  puts "Action: #{action}"

  stream do |out|
    case action
    when "apply"
      if HasRun.locked?
        runit("init", out)
        runit("plan", out)
        runit("apply", out)
      else
        runit("apply", out)
      end
    when "destroy"
      runit("destroy", out)
    end
  end

  if HasRun.get
    HasRun.set(false)
  else
    HasRun.set(true)
  end

  HasRun.locked

  response
end

get '/*' do
  halt 400, errcheck(4005)
end

error do
  status 500
  body errcheck(5000)
end
