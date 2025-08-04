package_id=""
challenge_object_id=""

proof=0xd4dd5b0000000000
github_id="0x-zeros"

# sui client object $challenge_object_id --json

# 找到有效证明，nonce: 6020564
# 证明 proof: d4dd5b0000000000
# proof:  Uint8Array(8) [
#   212, 221, 91, 0,
#     0,   0,  0, 0
# ]

sui client call --package $package_id \
  --module lets_move \
  --function get_flag \
  --args $proof $github_id $challenge_object_id 0x8