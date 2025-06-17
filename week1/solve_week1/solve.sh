#https://docs.sui.io/references/cli/ptb


package_id="0xc7b106c1391d281aac52a100c595d340a299eac70a0acb6718209bf34f3cc1e0"
challenge_object_id="0x9263b6e4b5d56205eea784ccb74225f0d398a4eaef12269185b1d052573c4665"



sui client call --package $package_id \
  --module solve \
  --function solve_get_flag \
  --args $challenge_object_id 0x8
