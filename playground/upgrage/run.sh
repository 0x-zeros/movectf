package_id="0x358f80b67da8c897e5b53fb96312f2d3267ac596fd2692b1b85b1c6758b02ecc"

upgrade_cap="0x0ba711a45f88850be6d2a957f41fc15ef585e60cccfbf08011f5b9af48bd9ccd"

counter_id="0xb36eaece9d621dafefab553ff5b6151b18f89aef7e584d43eda5e5dfd2140ead"

module="counter"





sui client call --package $package_id \
  --module $module \
  --function increment \
  --args $counter_id