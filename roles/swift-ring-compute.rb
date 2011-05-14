name "swift-ring-compute"

run_list(
    "recipe[swift::default]",
    "recipe[swift::ring-compute]"
)

description "A swift role to compute the ring files for the cluster. Should be installed on a single node"
