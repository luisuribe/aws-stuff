#!/usr/bin/env ruby
# Use this to create an ~/.ssh/config file with the list of all your EC2 instances. Better to put this script in a cronjob.

require 'json'

node_indexes = {}
instances = JSON.parse(`aws ec2 describe-instances --region us-east-1`)

ssh_config = {}
instances["Reservations"].sort_by { |r| r["Instances"].first["LaunchTime"] }.collect { |r| r["Instances"].first }.select  { |i| i["Tags"].detect { |t| t["Key"] == "Name" } }.select  { |i| i["PrivateIpAddress"] }.each do |i|
    tag = i["Tags"].detect { |t| t["Key"] == "Name" }
    next unless tag
    node_type = tag["Value"]
    node_index = node_indexes[node_type].to_i + 1
    node_indexes[node_type] = node_index
    ssh_config["#{node_type.downcase}-#{node_index}-#{i["InstanceId"]}"] = {
        "ipaddress" => i["PrivateIpAddress"]
    }
  end

ssh_config_text = "Host *\n"
ssh_config_text += ssh_config.collect { |k, h| ["Host #{k}", "\tHostName  #{h["ipaddress"]}"] }.flatten.join("\n")

File.write(File.expand_path("~/.ssh/config"), ssh_config_text)