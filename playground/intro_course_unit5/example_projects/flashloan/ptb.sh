
module="flashloan"

LOAN_PACKAGE_ID="0x9b8a08d5686177da4e4a8cde7c74964818a61e74ef381e09498f5d4ec8e480f4"

upgrade_cap="0x09afead86802570de7bdd578e2137839c9cf937b53d45509e3adf7b2df555a88"


LOAN_POOL_ID="0x20d8db798688d703bbc3722c71b59469bacd3c4e7f4f56329f47976ee0d50d5a"


sender2=""

# https://github.com/sui-foundation/sui-move-intro-course/blob/main/unit-five/lessons/2_hot_potato_pattern.md



# # deposit_pool
# sui client ptb \
# --split-coins gas "[10000]" \
# --assign coin \
# --move-call $LOAN_PACKAGE_ID::flashloan::deposit_pool @$LOAN_POOL_ID coin.0 \



# build a PTB that borrow() -> mint_nft() -> sell_nft() -> repay()
sui client ptb \
--move-call $LOAN_PACKAGE_ID::flashloan::borrow @$LOAN_POOL_ID 10000 \
--assign borrow_res \
--move-call $LOAN_PACKAGE_ID::flashloan::mint_nft borrow_res.0 \
--assign nft \
--move-call $LOAN_PACKAGE_ID::flashloan::sell_nft nft \
--assign repay_coin \
--move-call $LOAN_PACKAGE_ID::flashloan::repay @$LOAN_POOL_ID borrow_res.1 repay_coin \



# 查看 dynamic-field (好像无法在suivision.xyz上查看)
# sui client dynamic-field 0x84bdbfd13871ecf51af08d118f118ebeea9d0d815ec067d13cb497868cc471c7


# # upgrade
# sui client upgrade --upgrade-capability $upgrade_cap


# Quiz: What happen if you don't call repay() at the end of the PTB, please try it yourself
# Error executing transaction '6EYRxKAWWPgNE8gpPassnRUi2ccEZQXBVsRgkV4JJK9d': UnusedValueWithoutDrop { result_idx: 0, secondary_idx: 1 }
# sui client replay-transaction -t 6EYRxKAWWPgNE8gpPassnRUi2ccEZQXBVsRgkV4JJK9d