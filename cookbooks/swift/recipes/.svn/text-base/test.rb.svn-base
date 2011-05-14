require 'rubygems'
require 'json'
require 'net/http'


t = <<END 
{
  "id": "bc-default-swift",
  "description": "The default proposal for swift",
  "attributes": {
    "swift": {
    "cluster_hash": "fa8bea159b55bd7e",
    "cluster_admin_pw": "swauth",
    "replicas": "1"   
    }
  },
  "deployment": {
    "crowbar-revision": 0,
    "swift": {
      "elements": {},
      "element_order": [
        [ "swift-storage", "swift-proxy"],
    [ "swift-ring-compute"]
      ],
      "config": {
        "environment": "swift-config-base",
        "mode": "full",
        "transitions": false,
        "transition_list": []
      }
    }
  }
}
END


JSON.parse(t)