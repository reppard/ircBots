require 'json'
require "net/http"

def get_status_code(host)
  url = URI.parse("http://#{host}/")
  req = Net::HTTP.new(url.host, url.port)
  req.request_head(url.path).code
end

def responding?(code)
  !["404","500"].include?(code)
end

def login_available(host)
  `/bin/nc -z #{host} 22; echo $?`.chomp == "0"
end

tildes = JSON.parse(`/usr/bin/curl -s http://tilde.club/~pfhawkins/othertildes.json`)
hostnames = tildes.map{ |x,y| y.gsub(/(http|https):\/\//,'') }.map{ |x| x.gsub(/\/$/,'') }

statuss = {}

hostnames.each do |host|
  code = get_status_code(host)
  statuss[host] = {homepage_up: responding?(code), login_up: login_available(host)}
end

statuss["updated_on"] = Time.now

json_path = "/home/reppard/public_html/tilde_stats.json"
js_path   = "/home/reppard/public_html/js/tilde_stats.js"
File.open(json_path, 'w') { |file| file.write(JSON.pretty_generate(statuss)) }
File.open(js_path, 'w') { |file| file.write("var stats = #{JSON.pretty_generate(statuss)}") }
