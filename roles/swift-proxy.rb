name "swift-proxy"

run_list(
    "recipe[swift::default]",
    "recipe[swift::proxy]"
)

description "provides the proxy and authentication components to swift"