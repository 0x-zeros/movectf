package_id="0x358f80b67da8c897e5b53fb96312f2d3267ac596fd2692b1b85b1c6758b02ecc"

upgrade_cap="0x0ba711a45f88850be6d2a957f41fc15ef585e60cccfbf08011f5b9af48bd9ccd"

counter_id="0xb36eaece9d621dafefab553ff5b6151b18f89aef7e584d43eda5e5dfd2140ead"

module="counter"

# package_id_v2="0x11c06bfaa6de0ef6689fe6c9d37ae5571618f740ccb69065fc2c53f85093869e"
package_id_v3="0x498e71d44838cbffd2089daa1c65c398649bd4e0a7867d822b2a63134b24619d"




# sui client call --package $package_id \
#   --module $module \
#   --function increment \
#   --args $counter_id


sui client call --package $package_id_v3 \
  --module $module \
  --function increment \
  --args $counter_id


#upgrade
#sui client upgrade --upgrade-capability 0x0ba711a45f88850be6d2a957f41fc15ef585e60cccfbf08011f5b9af48bd9ccd