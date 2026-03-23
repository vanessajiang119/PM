#!/usr/bin/env python3
"""
RAG Document Ingestion Script
向量化和索引 PDF 文档
"""

import os
import json
import yaml
from pathlib import Path

# 配置路径
RAG_ROOT = Path(__file__).parent.parent
CONFIG_FILE = RAG_ROOT / "config.yml"
INDEX_DIR = RAG_ROOT / "index" / "metadata"
DATA_DIR = RAG_ROOT / "data" / "chroma"


def load_config():
    """加载 RAG 配置"""
    with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def get_knowledge_base_docs():
    """获取知识库文档列表"""
    config = load_config()
    return config.get('knowledge_base', {}).get('agent_documents', {})


def scan_pdf_documents(agent_name):
    """扫描指定 agent 的 PDF 文档"""
    docs_path = RAG_ROOT / "documents" / agent_name

    if not docs_path.exists():
        return []

    pdf_files = []
    for pdf in docs_path.rglob("*.pdf"):
        pdf_files.append({
            "path": str(pdf.relative_to(RAG_ROOT)),
            "filename": pdf.name,
            "size": pdf.stat().st_size
        })

    return pdf_files


def create_index_entry(pdf_info, agent_name, category="general"):
    """创建索引条目"""
    return {
        "id": f"{agent_name}_{category}_{pdf_info['filename']}",
        "agent": agent_name,
        "category": category,
        "filename": pdf_info['filename'],
        "path": pdf_info['path'],
        "size": pdf_info['size'],
        "indexed": False,
        "vector_id": None,
        "embedding_model": None
    }


def main():
    print("=" * 60)
    print("RAG Document Ingestion Script")
    print("=" * 60)

    # 加载配置
    config = load_config()
    print(f"\n[INFO] Loaded config: {config['rag']['name']} v{config['rag']['version']}")

    # 获取 agent 文档配置
    kb_docs = get_knowledge_base_docs()

    # 扫描所有 PDF 文档
    all_docs = []
    for agent_name in kb_docs.keys():
        pdfs = scan_pdf_documents(agent_name)
        for pdf in pdfs:
            # 获取分类
            category = "general"
            pdf_path = pdf['path']
            if "tessent_command" in pdf_path:
                if "scan_commands" in pdf_path:
                    category = "scan_commands"
                elif "mbist_commands" in pdf_path:
                    category = "mbist_commands"
                elif "atpg_commands" in pdf_path:
                    category = "atpg_commands"

            entry = create_index_entry(pdf, agent_name, category)
            all_docs.append(entry)
            print(f"[FOUND] {agent_name}: {pdf['filename']} ({category})")

    # 保存索引
    INDEX_DIR.mkdir(parents=True, exist_ok=True)
    index_file = INDEX_DIR / "document_index.json"

    index_data = {
        "documents": all_docs,
        "total": len(all_docs),
        "indexed": 0,
        "pending": len(all_docs)
    }

    with open(index_file, 'w', encoding='utf-8') as f:
        json.dump(index_data, f, indent=2, ensure_ascii=False)

    print(f"\n[INFO] Found {len(all_docs)} PDF documents")
    print(f"[INFO] Index saved to: {index_file}")
    print("\n[NOTE] Run vectorization with:")
    print("  pip install chromadb langchain pypdf")
    print("  python -m rag.scripts.vectorize --all")


if __name__ == "__main__":
    main()
