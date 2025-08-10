
module="marketplace"
module_widget="widget"

package_id="0x2921da92fa63115a02d7351736200087e40750a7b0ffa102acafb5a9c91368fc"

upgrade_cap=""
admin_cap=""
marketplace_id="0x742f54083e7b97aad15a54ad4ee60cd01fb1bc7466fd014167b55dd1cb300141"

widgets1="0x0d722132422ca31be10b38bff1638c5fb83f3ad4e2f1ee951b4ffa5970e2c321"
widgets2="0xa2db72481746d704ad3074cdee93112a5e44bd0e03dbb57f1d1ced6ae1c402af"
widgets3="0xdb6acdec05dea02fe0d816ddb2db55572a68f7f4e8644ccd2e4a08119756c00f"

widget_type=$package_id::$module_widget::Widget

sender2=""
# sender3=""

# # Create a new shared Marketplace
# sui client call \
#   --package $package_id \
#   --module $module \
#   --function create \
#   --type-args 0x2::sui::SUI #\
#   #--args


# # mint widget
# sui client call \
#   --package $package_id \
#   --module $module_widget \
#   --function mint

# sui client ptb \
#     --move-call $package_id::$module_widget::mint \
#     --move-call $package_id::$module_widget::mint


# # list
# sui client ptb --move-call $package_id::$module::list "<$widget_type,0x2::sui::SUI>"  @$marketplace_id @$widgets1 1000 \


# # list
# sui client ptb --move-call $package_id::$module::list "<$widget_type,0x2::sui::SUI>"  @$marketplace_id @$widgets2 2000 \
# --move-call $package_id::$module::list "<$widget_type,0x2::sui::SUI>"  @$marketplace_id @$widgets3 3000

# # delist
# sui client ptb --move-call $package_id::$module::delist_and_take "<$widget_type,0x2::sui::SUI>"  @$marketplace_id @$widgets3

# # delist
# sui client ptb --move-call $package_id::$module::delist_and_take "<$widget_type,0x2::sui::SUI>"  @$marketplace_id @$widgets2 --sender @$sender2



# # buy
# sui client ptb \
# --split-coins gas [2000] \
# --assign coin_paid \
# --move-call $package_id::$module::buy_and_take "<$widget_type,0x2::sui::SUI>"  @$marketplace_id @$widgets2 coin_paid --sender @$sender2


# buy
sui client ptb \
--move-call $package_id::$module::take_profits_and_keep "<0x2::sui::SUI>"  @$marketplace_id #--sender @$sender2



# 查看 dynamic-field (好像无法在suivision.xyz上查看)
# sui client dynamic-field 0x84bdbfd13871ecf51af08d118f118ebeea9d0d815ec067d13cb497868cc471c7


# 获取得到的 bag里kv pair里的id可以用来在suivision里面查询到object
# 0x2::dynamic_field::Field<0x2::object::ID, 0x292...68fc::marketplace::Listing>