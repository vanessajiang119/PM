# Chip Design Agent RAG 系统规划

## 1. 目录结构设计

```
/root/workspace/PM/rag/
├── config.yml                    # RAG全局配置
├── data/                         # 向量数据库存储
│   ├── chroma/                   # ChromaDB存储
│   │   └── chip_design/
│   └── cache/                    # 缓存文件
├── documents/                    # 源文档存储 (按角色分类)
│   ├── spec-architect/           # 系统架构师文档
│   │   ├── architecture_specs/
│   │   ├── performance_models/
│   │   └── interface_defs/
│   ├── spec-writer/              # 规格文档工程师文档
│   │   ├── functional_specs/
│   │   ├── timing_specs/
│   │   └── ip_documents/
│   ├── rtl-developer/            # RTL工程师文档
│   │   ├── design_guides/
│   │   ├── coding_standards/
│   │   └── code_examples/
│   ├── verification-engineer/    # 验证工程师文档
│   │   ├── uvm_guides/
│   │   ├── testbench_examples/
│   │   └── coverage_plans/
│   ├── debug-engineer/           # 调试工程师文档
│   │   ├── debug_guides/
│   │   ├── waveform_analysis/
│   │   └── issue_tracking/
│   ├── rtl-reviewer/             # RTL评审员文档
│   │   ├── review_checklists/
│   │   ├── lint_rules/
│   │   └── cdc_analysis/
│   ├── synthesis-engineer/       # 综合工程师文档
│   │   ├── dc_guides/
│   │   ├── sdc_examples/
│   │   └── optimization_tech/
│   ├── dft-engineer/             # DFT工程师文档
│   │   ├── scan_insertion/
│   │   ├── atpg_guides/
│   │   ├── mbist_designs/
│   │   └── tessent_command/       # Tessent命令统一指导
│   ├── physical-designer/        # 物理设计工程师文档
│   │   ├── floorplanning/
│   │   ├── place_route/
│   │   └── cts_guides/
│   ├── sta-engineer/             # STA工程师文档
│   │   ├── timing_guides/
│   │   ├── constraint_examples/
│   │   └── crosstalk_analysis/
│   ├── power-engineer/           # 功耗工程师文档
│   │   ├── power_analysis/
│   │   ├── low_power_design/
│   │   └── pdn_design/
│   ├── common/                   # 通用文档 (所有角色可用)
│   │   ├── eda_tools_guides/
│   │   ├── process_nodes/
│   │   └── standards/
│   └── shared/                   # 共享参考文档
├── index/                        # 索引文件
│   └── metadata/
├── logs/                         # RAG运行日志
├── scripts/                      # RAG管理脚本
│   ├── ingest.py                 # 文档摄取脚本
│   ├── query.py                  # 查询脚本
│   ├── rebuild_index.py          # 重建索引
│   └── stats.py                  # 统计信息
└── rag_config.py                 # RAG配置模块
```

## 2. 每个Agent角色的文档要求

### 2.1 spec-architect (系统架构师)
```
spec-architect/
├── architecture_specs/           # 架构规范文档
│   ├── *.pdf                     # 架构文档
│   └── *.md
├── performance_models/           # 性能建模文档
├── interface_defs/               # 接口定义文档
└── README.md                     # 目录说明
```
**预期文档类型**: 架构设计文档、性能分析报告、系统规格

### 2.2 rtl-developer (RTL工程师)
```
rtl-developer/
├── design_guides/                # 设计指南
├── coding_standards/             # 编码规范
├── code_examples/                # 代码示例
└── verilog_templates/            # Verilog模板
```
**预期文档类型**: Verilog编码规范、设计指南、代码模板

### 2.3 verification-engineer (验证工程师)
```
verification-engineer/
├── uvm_guides/                   # UVM指南
├── testbench_examples/           # 测试台示例
├── coverage_plans/               # 覆盖率计划
└── verification_reports/         # 验证报告
```
**预期文档类型**: UVM教程、测试台代码、覆盖率报告

### 2.4 dft-engineer (DFT工程师)
```
dft-engineer/
├── scan_insertion/               # Scan链插入
├── atpg_guides/                  # ATPG向量生成
├── mbist_designs/                # MBIST存储器测试
├── tessent_command/              # Tessent命令统一指导
│   ├── scan_commands/            # Scan相关命令
│   ├── mbist_commands/           # MBIST相关命令
│   ├── atpg_commands/            # ATPG相关命令
│   └── flow_scripts/             # 流程脚本
└── README.md                     # 目录说明
```
**预期文档类型**: DFT设计指南、Tessent工具命令、Scan/MBIST/ATPG脚本

> **Note**: DFT工程师优先使用 **Tessent** 工具进行 scan insertion、MBIST 和 ATPG 所有工作。

### 2.5 其他Agent角色类似...

## 3. RAG 优化方案 (支持1000+页文档)

### 3.1 文档分块策略

```yaml
chunking:
  # 基础分块参数
  chunk_size: 1024               # 每个chunk的token数
  chunk_overlap: 128             # chunk重叠区域

  # 文档类型自适应
  by_document_type:
    technical_specs:
      chunk_size: 2048           # 大规格文档用大chunk
      overlap: 256

    code_documentation:
      chunk_size: 512            # 代码相关用小chunk
      overlap: 64
      preserve_language: true    # 保持代码结构

    user_guides:
      chunk_size: 1024
      overlap: 128

  # 特殊处理
  special_handling:
    tables: "extract_as_json"     # 表格提取为JSON
    figures: "ocr_and_describe"   # 图片OCR+描述
    formulas: "latex_preserve"    # 公式保持LaTeX
```

### 3.2 向量模型选择

```yaml
embedding:
  # 主模型 (中文+英文支持)
  model: "text-embedding-3-large"  # OpenAI 或
  # model: "bge-m3"               # 本地模型选项

  # 模型参数
  dimensions: 3072                # 向量维度
  batch_size: 1000                # 批处理大小

  # 本地模型备选 (支持私有部署)
  local_models:
    - name: "bge-m3"
      dimension: 1024
      quantized: true             # 量化以节省内存
    - name: "bge-large-zh-v1.5"
      dimension: 1024
```

### 3.3 向量数据库选择

```yaml
vector_db:
  # 主数据库
  primary: "chroma"              # ChromaDB (开源、易用)
  # alternatives: ["qdrant", "milvus", "weaviate"]

  # ChromaDB配置
  chroma_config:
    persist_directory: "./data/chroma"
    collection_name: "chip_design"
    distance_metric: "cosine"    # 余弦相似度

  # 优化参数
  hnsw_config:
    ef_construction: 200         # 构建时搜索宽度
    ef_search: 200               # 查询时搜索宽度
    M: 16                        # 图连接数

  # 索引优化
  index_optimization:
    incremental_update: true     # 增量更新
    batch_indexing: true         # 批量索引
    num_workers: 4               # 并行worker数
```

### 3.4 检索优化

```yaml
retrieval:
  # 多路召回
  multi_way_recall:
    - method: "semantic"         # 语义召回
      weight: 0.4
    - method: "keyword"          # 关键词召回
      weight: 0.3
      engine: "bm25"
    - method: "exact"            # 精确匹配
      weight: 0.2
    - method: "agent_specific"   # Agent特定召回
      weight: 0.1

  # 重排序
  reranking:
    enabled: true
    model: "cross-encoder/ms-marco-MiniLM-L-6-v2"
    top_k: 10                    # 重排后保留top-k

  # 查询预处理
  query_processing:
    expand_query: true           # 查询扩展
    expand_with_synonyms: true   # 同义词扩展
    language_detection: true     # 语言检测

  # 上下文窗口
  context_window:
    max_chunks: 10               # 最多返回10个chunk
    max_tokens: 8000             # 最多8000 tokens
    aggregate_strategy: "longest" # 聚合策略
```

### 3.5 Agent特定RAG

```yaml
agent_rag:
  # 每个Agent的专用检索配置
  spec-architect:
    preferred_sources: ["spec-architect", "common"]
    search_depth: "detailed"
    include_cross_references: true

  rtl-developer:
    preferred_sources: ["rtl-developer", "common"]
    include_code_examples: true
    search_related_ip: true

  # 跨Agent知识共享
  cross_agent:
    enabled: true
    shared_sources: ["common", "shared"]
    reference_other_agents: true
```

### 3.6 大文档处理优化

```yaml
large_document_handling:
  # 1000+页文档特殊处理
  strategies:
    # 1. 文档结构感知
    structure_aware:
      enabled: true
      detect_sections: true      # 检测章节
      detect_headings: true      # 检测标题层级
      table_of_contents: true    # 构建目录

    # 2. 摘要预生成
    summarization:
      enabled: true
      summary_model: "gpt-4o"
      summary_chunk_size: 10     # 每10页生成摘要
      store_summaries: true

    # 3. 多级检索
    multi_level:
      enabled: true
      levels:
        - name: "overview"       # 概览级
          chunk_size: 4096
        - name: "detail"         # 细节级
          chunk_size: 1024
        - name: "reference"      # 参考级
          chunk_size: 512

    # 4. 增量索引
    incremental:
      enabled: true
      track_modifications: true
      update_strategy: "smart"   # 智能更新

  # 性能优化
  performance:
    cache_embeddings: true       # 缓存embeddings
    parallel_processing: true    # 并行处理
    memory_limit: "16GB"         # 内存限制
    batch_processing: true       # 批量处理
```

### 3.7 检索结果后处理

```yaml
post_processing:
  # 结果去重
  deduplication:
    enabled: true
    similarity_threshold: 0.95

  # 结果排序
  ranking:
    diversity_weight: 0.2        # 多样性权重
    recency_weight: 0.1          # 时效性权重
    authority_weight: 0.1       # 权威性权重

  # 结果格式化
  formatting:
    include_source: true         # 包含来源
    include_page_number: true    # 包含页码
    include_relevance_score: true # 包含相关性分数
    max_source_length: 200       # 来源最大长度
```

## 4. API 接口设计

```yaml
api:
  endpoints:
    # 文档摄取
    - path: "/rag/ingest"
      method: POST
      description: "上传文档并索引"

    # 文档查询
    - path: "/rag/query"
      method: POST
      description: "RAG查询"
      params:
        - query: string
        - agent_role: string     # Agent角色
        - top_k: int
        - include_sources: bool

    # 索引管理
    - path: "/rag/rebuild"
      method: POST
      description: "重建索引"

    # 状态查询
    - path: "/rag/stats"
      method: GET
      description: "获取RAG统计信息"
```

## 5. 与现有Agent系统集成

```yaml
integration:
  # 与Agent Skills集成
  agent_integration:
    hook_name: "on_rag_query"    # Agent调用RAG的hook
    auto_retrieve: true          # 自动检索相关文档

  # Memory系统集成
  memory_integration:
    store_rag_results: true      # 存储RAG结果
    context_window: 5            # 保留最近5次结果

  # 与define.yml集成
  config_in_define:
    enabled: true
    section: "rag"
```

## 6. 实施计划

### Phase 1: 基础RAG系统 (1周)
- [ ] 创建目录结构
- [ ] 实现基本文档摄取
- [ ] 实现基本语义检索
- [ ] 配置ChromaDB

### Phase 2: 性能优化 (1周)
- [ ] 实现查询扩展
- [ ] 实现重排序
- [ ] 优化大文档处理

### Phase 3: Agent集成 (1周)
- [ ] 与现有Agent hooks集成
- [ ] 实现Agent特定检索
- [ ] 添加Memory集成

### Phase 4: 运维工具 (1周)
- [ ] 监控和统计
- [ ] 增量更新机制
- [ ] 备份和恢复

## 7. 依赖项

```yaml
requirements:
  python_packages:
    - chromadb>=0.4.0
    - langchain>=0.1.0
    - langchain-community>=0.0.10
    - pypdf>=3.0.0
    - pydantic>=2.0.0
    - tiktoken>=0.5.0
    - faiss-cpu (可选，本地向量搜索)

  system_requirements:
    - python>=3.11
    - 16GB RAM (最小)
    - 100GB 磁盘空间
```

---

请确认以上规划是否符合您的需求，确认后我将写入 define.yml 并创建相关文件。
