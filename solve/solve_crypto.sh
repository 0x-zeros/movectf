package_id="0x0cb4212047907428bf5755a5d0d309b4cdac9734b08ce9b388c180cfe3ef0cea"
module="crypto"

flag="flag{5Ui_M0Ve_CONtrAC7}"


sui client call --package $package_id \
  --module $module \
  --function decrypt_flag \
  --args $flag