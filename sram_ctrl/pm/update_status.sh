#!/bin/bash
# =============================================================================
# Project Status Update Script
# 用于自动更新项目状态到 pm/project_sram.md
# 使用方法: ./update_status.sh <project_name> <task_name> <status>
# 示例: ./update_status.sh sram_ctrl "覆盖率检查" "完成"
# =============================================================================

PROJECT_NAME=${1:-sram_ctrl}
TASK_NAME=${2:-"任务更新"}
STATUS=${3:-完成}
PROJECT_DIR="/root/workspace/PM/${PROJECT_NAME}"
STATUS_FILE="${PROJECT_DIR}/pm/project_sram.md"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}正在更新项目状态...${NC}"
echo "项目: $PROJECT_NAME"
echo "任务: $TASK_NAME"
echo "状态: $STATUS"

# 检查文件是否存在
if [ ! -f "$STATUS_FILE" ]; then
    echo -e "${YELLOW}错误: 项目状态文件不存在: ${STATUS_FILE}${NC}"
    exit 1
fi

# 获取当前日期
CURRENT_DATE=$(date +%Y-%m-%d)

# 状态标记转换
STATUS_MARK=""
case $STATUS in
    完成|✅|complete|done)
        STATUS_MARK="✅ 完成"
        ;;
    进行中|🔄|in_progress)
        STATUS_MARK="🔄 进行中"
        ;;
    待开始|⏳|pending)
        STATUS_MARK="⏳ 待开始"
        ;;
    阻塞|❌|blocked)
        STATUS_MARK="❌ 阻塞"
        ;;
    *)
        STATUS_MARK="✅ 完成"
        ;;
esac

# 使用awk来在任务历史表格中插入新行 (只在包含"任务历史"的表格中插入)
awk -v date="$CURRENT_DATE" -v task="$TASK_NAME" -v status="$STATUS_MARK" '
/^\| 日期 \| 任务 \| 状态 \|$/ {
    found_table = 1
    print
    next
}
found_table && /^\|---/ {
    print
    print "| " date " | " task " | " status " |"
    found_table = 0
    next
}
{print}
' "$STATUS_FILE" > "${STATUS_FILE}.tmp" && mv "${STATUS_FILE}.tmp" "$STATUS_FILE"

# 更新项目状态最后修改时间
sed -i "s/| \*\*更新日期\*\* | .* |/| **更新日期** | ${CURRENT_DATE} |/" "$STATUS_FILE"

echo -e "${GREEN}项目状态已更新!${NC}"
echo ""
echo "更新内容:"
echo "  日期: ${CURRENT_DATE}"
echo "  任务: ${TASK_NAME}"
echo "  状态: ${STATUS_MARK}"
echo ""
echo "查看完整状态: cat ${STATUS_FILE}"
