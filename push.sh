#!/bin/bash

# MHAdSDK-ToBidAdapter-Demo 推送脚本
# 用法: ./push.sh "commit message"
# 首次使用需设置 token: export GH_TOKEN="ghp_你的token"

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

# 检查 token
if [ -z "$GH_TOKEN" ]; then
    echo "错误: 请先设置 GH_TOKEN 环境变量"
    echo "  export GH_TOKEN=\"ghp_你的token\""
    exit 1
fi

REMOTE_URL="https://MaplehazeAd:${GH_TOKEN}@github.com/MaplehazeAd/MHAdSDK-ToBidAdapter-Demo.git"

# 检查是否有变更
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo "没有需要提交的变更"
    exit 0
fi

# 提交信息
if [ -z "$1" ]; then
    echo "用法: ./push.sh \"commit message\""
    exit 1
fi

git add .
git commit -m "$1"
git push "$REMOTE_URL" main --tags

echo "推送完成!"
