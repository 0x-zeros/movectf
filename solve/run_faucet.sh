#!/bin/bash

# Faucet 定时调用启动脚本

echo "🚀 启动 Sui Faucet 定时调用程序..."

# 检查环境变量文件
if [ ! -f ".env" ]; then
    echo "❌ 未找到 .env 文件，请先配置环境变量"
    echo "📝 参考 FAUCET_README.md 进行配置"
    exit 1
fi

# 检查依赖是否安装
if [ ! -d "node_modules" ]; then
    echo "📦 安装依赖..."
    npm install
fi

# 检查 TypeScript 是否安装
if ! command -v npx &> /dev/null; then
    echo "❌ 未找到 npx，请先安装 Node.js"
    exit 1
fi

echo "✅ 依赖检查完成"
echo "🔧 启动程序..."

# 运行程序
npx ts-node src/faucet.ts
