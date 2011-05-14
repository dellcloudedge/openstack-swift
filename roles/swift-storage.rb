name "swift-storage"

run_list(
    "recipe[swift::default]",
    "recipe[swift::storage]"
)
description "configures a swift storage node, including partitioning disks, creating XFS"