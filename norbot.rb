require 'socket'
require 'io/console'
require 'json'

def join_channel channel
  @current_channel = channel.gsub(/^\/\w+/,'')
  @socket.sendmsg("JOIN #{@current_channel}\r\n",0)
end

def authen
  @socket.sendmsg("NICK #{@nick}\r\n",0)
  @socket.sendmsg("USER rubot * * : rubybottest Test User\r\n",0)
end

def send_privmsg input
  str_to_send = "PRIVMSG #{@current_channel} :#{input}".gsub(/\n/,'')
  @socket.send("#{str_to_send}\r\n\r\n",0)
end

def pong(msg)
  @server = msg.gsub(/PING :/,'')
  @socket.send("PONG\r\n",0)
end

def yomama
  joke = JSON.parse(`curl -s http://api.yomomma.info`)["joke"]
  $stdout.print(joke + "\n")
  send_privmsg(joke)
end

def norris
  joke = JSON.parse(`curl -s http://api.icndb.com/jokes/random`)["value"]["joke"]
  $stdout.print(joke + "\n")
  send_privmsg(joke)
end

def process_line(line)
  join_channel(@channel) if line =~ /MOTD/
  pong(line) if line =~ /PING/
  norris if line =~ /!norris/
  yomama if line =~ /!yomama/
end

def set_options args
  if args.size < 3
    puts "USAGE: ruby norbot.rb <server> <nick> <channel>"
    exit 1
  end
  @server  = args[0]
  @nick    = args[1]
  @channel = "##{args[2]}"
end

set_options(ARGV)
$stdout.sync = true
@socket = TCPSocket.open(@server, 6667)
@socket.send("NICK #{@nick}\r\n",0)
@socket.send("USER rubot * * : rubybottest Test User\r\n",0)


while true
  line = @socket.gets
  puts line
  process_line(line)
end
