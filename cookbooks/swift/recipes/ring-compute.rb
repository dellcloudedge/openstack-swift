# Copyright 2011, Dell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author: andi abes
#

include_recipe 'swift::rsync'

##
# Assumptions:
#  - The partitions to be used on each node are in node[:swift][:devs]
#  - only nodes which have the swift-storage role assigned are used.


env_filter = " AND swift_config_environment:#{node[:swift][:config][:environment]}"
nodes = search(:node, "roles:swift-storage#{env_filter}")

=begin
  http://swift.openstack.org/howto_installmultinode.html

swift-ring-builder account.builder add z$ZONE-$STORAGE_LOCAL_NET_IP:6002/$DEVICE $WEIGHT
swift-ring-builder container.builder add z$ZONE-$STORAGE_LOCAL_NET_IP:6001/$DEVICE $WEIGHT
swift-ring-builder object.builder add z$ZONE-$STORAGE_LOCAL_NET_IP:6000/$DEVICE $WEIGHT

      command  "swift-ring-builder object.builder add z#{zone}-#{storage_ip_addr}:6000/#{disk[:name]} #{weight}"
=end


####
# collect the current contents of the ring files.
disks_a= []
disks_c= []
disks_o= []
## collect the nodes that need to be notified when ring files are updated
target_nodes=[]
zone_round_robin =1
replicas = node[:swift][:replicas]

nodes.each { |node|    
  storage_ip = Evaluator.get_ip_by_type(node, :storage_ip_expr)
  target_nodes << storage_ip
  Chef::Log.info "Looking at node: #{storage_ip}" 
  disks=node[:swift][:devs] 
  next if disks.nil?
  disks.each {|disk|
    d = {:ip => storage_ip, :dev_name=>disk[:name], :zone=>zone_round_robin, :weight=>100, :port => 6000}
    disks_o << d
     (d = d.dup) [:port] = 6001
    disks_c << d
     (d = d.dup)[:port] = 6002
    disks_a << d 
  }
  zone_round_robin = (zone_round_robin + 1) % replicas 
}

replicas = node[:swift][:replicas]
min_move = node[:swift][:min_part_hours]
parts = node[:swift][:partitions]

swift_ringfile "account.builder" do
  disks disks_a
  replicas replicas
  min_part_hours min_move
  partitions parts
  action [:apply, :rebalance]
end
swift_ringfile "container.builder" do
  disks disks_c
  replicas replicas
  min_part_hours min_move
  partitions parts
  action [:apply, :rebalance]
end
swift_ringfile "object.builder" do
  disks disks_o
  replicas replicas
  min_part_hours min_move
  partitions parts
  action [:apply, :rebalance]
end


Chef::Log.info "nodes to notify: #{target_nodes.join ' '}"
target_nodes.each {|t|
  execute "push account ring-to #{t}" do
    command "rsync account.ring.gz #{node[:swift][:user]}@#{t}::ring"
    cwd "/etc/swift"
    action :nothing 
    subscribes :run, resources(:swift_ringfile =>"account.builder")  
  end  
  execute "push container ring-to #{t}" do
    command "rsync container.ring.gz #{node[:swift][:user]}@#{t}::ring"
    cwd "/etc/swift"
    action :nothing
    subscribes :run, resources(:swift_ringfile =>"container.builder")  
  end
  execute "push object ring-to #{t}" do
    command "rsync object.ring.gz #{node[:swift][:user]}@#{t}::ring"
    cwd "/etc/swift"
    action :nothing
    subscribes :run, resources(:swift_ringfile =>"object.builder")
  end 
}
