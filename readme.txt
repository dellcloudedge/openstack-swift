* Overview

Swift is part of Openstack, and provides a distributed blob storage. This barclamp installs swift.
Swift includes the following components:
 - Proxy node- provides the API to the cluster, including authentication.
 - Storage nodes - provide storage for clsuter.

* Roles
The following node roles are definied in this cookbook:
 - Storage node - configures a node to be used as a storage node
 - Proxy node - configures a node to be a proxy. each proxy node will have a memcached server installed. all proxy nodes are updated with all the memcached severs' addresses (listening on the internal IP addresses)
 - Proxy node with account management - same as proxy node, but allows account_management.
 - ring-compute-node - computes and update the ring file (contains information about what partitions are stored where). The ring file distributed to other cluster members via rsync (rsyncd configured on this node, other nodes configured to sync periodically)


* General comments

 The cookbook is designed to be useful in many different environments without requiring changes to the recpies themselvs. This is achieved by using attributes which provide expressions evaluated at recpie execution time. For example:

default[:swift][:admin_ip_expr] = "node[:ipaddress]" 
default[:swift][:storage_ip_expr] = "node[:ipaddress]"

Instructs the recipes to look at the ipaddress attribute set on the node for use for both the admin and storage networks. In environments where more copmlex address allocation is present, these expressions can be modified (even to function calls).
Look in the attributes\default.rb for the full set of expressions provided.

