package_id="0x582539dd35a0df2c6b10963caeb3babe37dbedbe1f86f1ba6cc4094f771905fb"

upgrade_cap="0xc2b4b90f936d23b476e9febe97519fb971167eeeabf39d363c016cdc276ccddb"

counter_id="0xb7d28b0e6d589cbcae796a155efa6ed50872903babaacce3c7eda0f6e7a96db1"
admin_cap="0x078a9494f0e0edc9563e5a589170e0b532802fc8b305fbf0735548100d5fb571"

module="counter"

# package_id_v2="0x11c06bfaa6de0ef6689fe6c9d37ae5571618f740ccb69065fc2c53f85093869e"
package_id_v3=""




sui client call --package $package_id \
  --module $module \
  --function increment \
  --args $counter_id


# sui client call --package $package_id_v3 \
#   --module $module \
#   --function increment \
#   --args $counter_id


#upgrade
#sui client upgrade --upgrade-capability 0x0ba711a45f88850be6d2a957f41fc15ef585e60cccfbf08011f5b9af48bd9ccd