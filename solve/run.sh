# package_id="0xdd77e732895051cf27d267c007a75037d2da8f25202a746c58aca11e0eb3c586"
# module="ez_game"
# random_object_id=0x8

# github_id="0x-zeros"



# # sui client call --package $package_id \
# #   --module $module \
# #   --function init_game \
# #   --args $random_object_id


# challenge_object_id="0xd7641830f4a727e6406f3709895b51bba3147386fbbc5ec6fff80d3921fe6114"

# # sui client object $challenge_object_id --json
# # "target_amount": "19"


# # user_input: vector<u64>
# user_input=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
# # [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] 23个1
# # = 两边不能有空格； [ 1, 这样有空格的也会报错 （shell的语法）

# sui client call --package $package_id \
#   --module $module \
#   --function get_flag \
#   --args $user_input $challenge_object_id