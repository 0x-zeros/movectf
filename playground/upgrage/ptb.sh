#!/bin/bash

# testnet
# test "sui client replay-transaction"
# sui client replay-transaction -t Girf1xZ9v8bkv2eHk4XFJ7Apa9zmRaH3hQgQaV5pxtzZ
# Unsupported chain identifier for replay -- only testnet and mainnet are supported currently: 9c44a5af

# # 方法1：在命令前直接设置
# MOVE_VM_STEP=1 sui client replay-transaction <transaction_id>

# # 方法2：使用export（对当前shell会话有效）
# export MOVE_VM_STEP=1
# sui client replay-transaction <transaction_id>


module="counter"

package_id="0xa3352308c75ca7a5e3a9eb2b2225a68dce7626f337058f0848108bc316e6bdc8"
package_id_v2=""

upgrade_cap="0x60ddf89517470e20cc2d79f9ea29accabf0ff2c7d4456b462a395ef5e33e7a0f"
admin_cap="0x039180856ea936cd1d5cd46f118e843f50bf9d189d07b30390097dfce0e4ee05"
counter_id="0x17ceb3b2937d79c14ea8abd5f60be0ffc6394b08a25e3477f4e446b2f8856872"



# call
# sui client call --package $package_id \
#   --module $module \
#   --function increment \
#   --args $counter_id




# https://docs.sui.io/references/cli/ptb


#  --move-call <PACKAGE::MODULE::FUNCTION> <TYPE_ARGS> <FUNCTION_ARGS>
#           Make a move call to a function.

#           Examples:
#            --move-call std::option::is_none <u64> none
#            --assign a none
#            --move-call std::option::is_none <u64> a

# --move-call 0x1::option::is_none "<u64>" my_variable


# sui client ptb \
# --assign counter @$counter_id \
# --move-call $package_id::$module::increment counter \
# --move-call $package_id::$module::increment counter \
# --move-call $package_id::$module::increment counter


# sui client ptb \
# --assign counter @$counter_id \
# --move-call $package_id::$module::increment counter --dry-run


sui client ptb \
--assign counter @$counter_id \
--move-call $package_id::$module::increment counter #--dev-inspect

