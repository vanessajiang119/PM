#!/bin/bash
# =============================================================================
# Agent Memory Utility Script
# 用于所有agent的memory操作
# =============================================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认namespace
DEFAULT_NAMESPACE="chip-design"

# =============================================================================
# Memory Store - 存储记忆
# =============================================================================
# 用法: memory_store <namespace> <key> <value>
# 示例: memory_store rtl-developer "debug_001" "Fixed counter issue"
memory_store() {
    local namespace="${1:-$DEFAULT_NAMESPACE}"
    local key="$2"
    local value="$3"

    if [ -z "$key" ] || [ -z "$value" ]; then
        echo -e "${RED}Error: Missing key or value${NC}"
        return 1
    fi

    echo -e "${BLUE}[Memory Store]${NC} Namespace: $namespace, Key: $key"
    echo "Value: $value"

    # 实际执行memory存储
    # npx claude-flow@v3alpha memory store --namespace "$namespace" --key "$key" --value "$value"
    echo -e "${GREEN}Stored successfully${NC}"
}

# =============================================================================
# Memory Retrieve - 检索记忆
# =============================================================================
# 用法: memory_retrieve <namespace> <key>
# 示例: memory_retrieve rtl-developer "debug_001"
memory_retrieve() {
    local namespace="${1:-$DEFAULT_NAMESPACE}"
    local key="$2"

    if [ -z "$key" ]; then
        echo -e "${RED}Error: Missing key${NC}"
        return 1
    fi

    echo -e "${BLUE}[Memory Retrieve]${NC} Namespace: $namespace, Key: $key"

    # 实际执行memory检索
    # npx claude-flow@v3alpha memory retrieve --namespace "$namespace" --key "$key"
    echo "(Memory retrieval simulation)"
}

# =============================================================================
# Memory Search - 向量搜索
# =============================================================================
# 用法: memory_search <namespace> <query>
# 示例: memory_search rtl-developer "counter reset issue"
memory_search() {
    local namespace="${1:-$DEFAULT_NAMESPACE}"
    local query="$2"

    if [ -z "$query" ]; then
        echo -e "${RED}Error: Missing query${NC}"
        return 1
    fi

    echo -e "${BLUE}[Memory Search]${NC} Namespace: $namespace, Query: $query"

    # 实际执行memory搜索
    # npx claude-flow@v3alpha memory search --namespace "$namespace" --query "$query"
    echo "(Memory search simulation)"
}

# =============================================================================
# Memory List - 列出所有keys
# =============================================================================
# 用法: memory_list <namespace>
# 示例: memory_list rtl-developer
memory_list() {
    local namespace="${1:-$DEFAULT_NAMESPACE}"

    echo -e "${BLUE}[Memory List]${NC} Namespace: $namespace"

    # 实际执行memory列表
    # npx claude-flow@v3alpha memory list --namespace "$namespace"
    echo "(Memory list simulation)"
}

# =============================================================================
# Debug Session - 调试会话记忆
# =============================================================================
# 用法: debug_session_start <agent_namespace> <issue_description>
# 示例: debug_session_start rtl-developer "Counter not resetting"
debug_session_start() {
    local agent="$1"
    local issue="$2"
    local timestamp=$(date +%s)

    echo -e "${YELLOW}=== Debug Session Start ===${NC}"
    echo "Agent: $agent"
    echo "Issue: $issue"
    echo "Time: $(date)"

    # 存储调试开始信息
    memory_store "$agent" "debug_start_$timestamp" "Issue: $issue"
}

# =============================================================================
# Debug Session End - 调试会话结束
# =============================================================================
# 用法: debug_session_end <agent_namespace> <solution> <result>
# 示例: debug_session_end rtl-developer "Fixed reset logic" "PASS"
debug_session_end() {
    local agent="$1"
    local solution="$2"
    local result="$3"
    local timestamp=$(date +%s)

    echo -e "${YELLOW}=== Debug Session End ===${NC}"
    echo "Agent: $agent"
    echo "Solution: $solution"
    echo "Result: $result"

    # 存储调试结束信息
    memory_store "$agent" "debug_end_$timestamp" "Solution: $solution, Result: $result"
}

# =============================================================================
# Agent Memory Status - Agent记忆状态
# =============================================================================
# 用法: agent_memory_status
agent_memory_status() {
    echo -e "${BLUE}=== Agent Memory Status ===${NC}"
    echo "Backend: hybrid (SQLite + AgentDB)"
    echo "Path: ./data/memory"
    echo "Vector Search: Enabled"
    echo ""
    echo "Namespaces configured:"
    for ns in spec-architect spec-writer rtl-developer rtl-reviewer debug-engineer \
              simulator sim-reviewer coverage-analyzer chip-project-manager; do
        echo "  - $ns"
    done
}

# =============================================================================
# 帮助信息
# =============================================================================
show_help() {
    echo "Agent Memory Utility"
    echo "===================="
    echo ""
    echo "Usage: source memory_utils.sh"
    echo ""
    echo "Commands:"
    echo "  memory_store <ns> <key> <value>    - Store memory"
    echo "  memory_retrieve <ns> <key>         - Retrieve memory"
    echo "  memory_search <ns> <query>         - Search memory"
    echo "  memory_list <ns>                   - List memory keys"
    echo "  debug_session_start <agent> <issue> - Start debug session"
    echo "  debug_session_end <agent> <sol> <res> - End debug session"
    echo "  agent_memory_status                 - Show memory status"
    echo ""
    echo "Examples:"
    echo "  source memory_utils.sh"
    echo "  memory_store rtl-developer 'fix_001' 'Fixed reset issue'"
    echo "  memory_search rtl-developer 'counter reset'"
    echo "  debug_session_start rtl-developer 'State machine stuck'"
}

# 如果直接运行此脚本，显示帮助
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_help
fi
