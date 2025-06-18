#https://docs.sui.io/references/cli/ptb


package_id="0x337ec7c958b5dd02a292ed32ade51797efbfcbba232109a1d446c69e9e879ca5"
challenge_object_id="0x74b003cb6532130df6c799f0c1fc84b99f63335e1be3f7e113e93f67c2eeb40b"



sui client call --package $package_id \
  --module solve \
  --function solve_get_flag \
  --args $challenge_object_id 0x8
