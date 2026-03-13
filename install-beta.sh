#!/bin/bash
set -e

echo "🚀 开始安装钉钉连接器 v0.8.0-beta..."

# 检查 OpenClaw 是否已安装
if ! command -v openclaw &> /dev/null; then
    echo "❌ 错误：未检测到 OpenClaw，请先安装 OpenClaw"
    exit 1
fi

# 备份当前配置
echo "📦 备份当前配置..."
BACKUP_FILE="$HOME/.openclaw/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)"
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    cp "$HOME/.openclaw/openclaw.json" "$BACKUP_FILE"
    echo "✅ 配置已备份到: $BACKUP_FILE"
else
    echo "⚠️  未找到配置文件，跳过备份"
fi

# 克隆升级分支
echo "📥 克隆升级分支..."
cd /tmp
rm -rf dingtalk-openclaw-connector-beta
git clone --single-branch --branch feat/migrate-to-openclaw-sdk \
    https://github.com/DingTalk-Real-AI/dingtalk-openclaw-connector.git \
    dingtalk-openclaw-connector-beta

cd dingtalk-openclaw-connector-beta
npm install

# 卸载旧版本
echo "🗑️  卸载旧版本..."
openclaw plugins uninstall dingtalk-connector || true

# 安装新版本
echo "✨ 安装新版本..."
openclaw plugins install -l .

# 重启 Gateway
echo "🔄 重启 Gateway..."
openclaw gateway restart

echo ""
echo "✅ 安装完成！"
echo ""
echo "📖 请查看 README_UPGRADE.md 了解新功能"
echo "🐛 遇到问题请提交：https://github.com/DingTalk-Real-AI/dingtalk-openclaw-connector/issues"
echo ""
echo "💡 如需回滚："
echo "   1. 恢复配置：cp $BACKUP_FILE ~/.openclaw/openclaw.json"
echo "   2. 安装旧版本：openclaw plugins install @dingtalk-real-ai/dingtalk-connector@latest"
