
KIOSK_PACKAGE_ID="0x6d6c626fbf1fb00928eb0ae47163b1b3f1e8fc306f7c2d8106bfea21119d1bf5"

# upgrade_cap="0xd2be292daa8824bc5742dce4f04ef55551c18bc7e01c832232fdbe1a3d0d8a11"
KIOSK_PUBLISHER="0x10acfa89a733fee1f5d67095827f9154d2f02da4fec52edfa240cdb83dba8fbc"

KIOSK_OWNER_CAP="0x7e2e81fbdfbd9c35f18d43ac204fc7cde20ef6f301bd5053a8ceb4cf8ede15df"
KIOSK="0xeb6e7e1c83747d7cbd9b724a66449a45ecb0108946d53a891bdc11c263f92d04"

KIOSK_TRANSFER_POLICY="0xe01300b3fb2c079b1cfead3c73920d9d19c82a0b675b96b53dd7801a96f98273"
KIOSK_TRANSFER_POLICY_CAP="0xbf665b59b1a7276f7ee7d26ea6d16b37d7f937be92ab64c699274b74b382cbfd"


# 注意注释掉的这样的引用号不对
# KIOSK_TSHIRT=“0x875766ef2f81dfb8c85f1af7b1cc91b12f9135b0341d967dbb90e1edae4f35b7”
KIOSK_TSHIRT="0x875766ef2f81dfb8c85f1af7b1cc91b12f9135b0341d967dbb90e1edae4f35b7"

buyer_address=""



# # kiosk and kiosk owner cap
# sui client call --package $KIOSK_PACKAGE_ID --module kiosk --function new_kiosk


# # policy and policy cap
# sui client call --package $KIOSK_PACKAGE_ID --module kiosk --function new_policy --args $KIOSK_PUBLISHER


# # adds a Rule to the `TransferPolicy`
# sui client call --package $KIOSK_PACKAGE_ID --module fixed_royalty_rule --function add --args $KIOSK_TRANSFER_POLICY $KIOSK_TRANSFER_POLICY_CAP 10 100 --type-args $KIOSK_PACKAGE_ID::kiosk::TShirt



# # new tshirt and place it in the kiosk
# sui client ptb \
# --move-call $KIOSK_PACKAGE_ID::kiosk::new_tshirt \
# --assign tshirt \
# --move-call $KIOSK_PACKAGE_ID::kiosk::place @$KIOSK @$KIOSK_OWNER_CAP tshirt \



# #  listed a tshirt with price 10_000 MIST
# sui client ptb \
# --move-call $KIOSK_PACKAGE_ID::kiosk::list @$KIOSK @$KIOSK_OWNER_CAP @$KIOSK_TSHIRT 10000 \



# buy a tshirt
sui client ptb \
--assign price 10000 \
--split-coins gas "[price]" \
--assign coin \
--move-call $KIOSK_PACKAGE_ID::kiosk::buy @$KIOSK @$KIOSK_TSHIRT coin.0 \
--assign buy_res \
--move-call $KIOSK_PACKAGE_ID::fixed_royalty_rule::fee_amount "<$KIOSK_PACKAGE_ID::kiosk::TShirt>" @$KIOSK_TRANSFER_POLICY price \
--assign fee_amount \
--split-coins gas "[fee_amount]" \
--assign coin \
--move-call $KIOSK_PACKAGE_ID::fixed_royalty_rule::pay "<$KIOSK_PACKAGE_ID::kiosk::TShirt>" @$KIOSK_TRANSFER_POLICY buy_res.1 coin.0 \
--move-call $KIOSK_PACKAGE_ID::kiosk::confirm_request @$KIOSK_TRANSFER_POLICY buy_res.1 \
--move-call 0x2::transfer::public_transfer "<$KIOSK_PACKAGE_ID::kiosk::TShirt>" buy_res.0 @$buyer_address
