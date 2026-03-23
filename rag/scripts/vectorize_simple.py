#!/usr/bin/env python3
"""
RAG Vectorization Script - Simple Version
使用文本存储和简单关键词匹配，不需要下载 embedding 模型
"""

import os
import sys
import json
import yaml
import re
from pathlib import Path

# 配置路径
RAG_ROOT = Path(__file__).parent.parent
CONFIG_FILE = RAG_ROOT / "config.yml"
INDEX_FILE = RAG_ROOT / "index" / "metadata" / "document_index.json"
DATA_DIR = RAG_ROOT / "data" / "chroma"


def load_config():
    """加载 RAG 配置"""
    with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def load_index():
    """加载文档索引"""
    with open(INDEX_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)


def simple_chunk_text(text, chunk_size=2048, overlap=256):
    """简单文本分块"""
    chunks = []
    start = 0
    text_len = len(text)

    while start < text_len:
        end = start + chunk_size
        chunk = text[start:end]

        # 尝试在句号或换行符处分割
        if end < text_len:
            last_period = max(chunk.rfind('.\n'), chunk.rfind('.\n\n'), chunk.rfind('\n\n'))
            if last_period > chunk_size // 2:
                chunk = chunk[:last_period + 1]
                end = start + last_period + 1

        chunks.append(chunk.strip())
        start = end - overlap

    return chunks


def extract_text_from_pdf(pdf_path):
    """从 PDF 提取文本"""
    try:
        from pypdf import PdfReader
        reader = PdfReader(str(pdf_path))
        text = ""
        for page in reader.pages:
            text += page.extract_text() + "\n"
        return text
    except Exception as e:
        print(f"[ERROR] Failed to extract text: {e}")
        return ""


def main():
    print("=" * 60)
    print("RAG Vectorization - Simple Text Storage")
    print("=" * 60)

    # 加载配置和索引
    config = load_config()
    index_data = load_index()

    print(f"\n[INFO] Config: {config['rag']['name']} v{config['rag']['version']}")
    print(f"[INFO] Total documents: {index_data['total']}")

    # 创建存储目录
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    chunks_dir = DATA_DIR / "chunks"
    chunks_dir.mkdir(exist_ok=True)

    # 处理每个文档
    docs = index_data.get('documents', [])
    success_count = 0

    for doc in docs:
        if doc.get('indexed', False):
            print(f"[SKIP] Already indexed: {doc['filename']}")
            continue

        doc_path = RAG_ROOT / doc['path']
        if not doc_path.exists():
            print(f"[WARN] Document not found: {doc_path}")
            continue

        print(f"\n[INFO] Processing: {doc['filename']}")

        # 提取文本
        text = extract_text_from_pdf(doc_path)
        if not text.strip():
            print(f"[WARN] No text extracted")
            continue

        print(f"[INFO] Extracted {len(text)} characters")

        # 分块
        chunks = simple_chunk_text(text, chunk_size=2048, overlap=256)
        print(f"[INFO] Created {len(chunks)} chunks")

        if not chunks:
            continue

        # 存储到 JSON 文件
        doc_id = doc['id']
        chunk_data = {
            "document_id": doc_id,
            "filename": doc['filename'],
            "agent": doc['agent'],
            "category": doc['category'],
            "total_chunks": len(chunks),
            "chunks": []
        }

        for i, chunk in enumerate(chunks):
            # 提取关键词用于简单搜索
            words = re.findall(r'\b[a-zA-Z_][a-zA-Z0-9_]{2,}\b', chunk.lower())
            keywords = list(set(words))[:50]  # 最多50个关键词

            chunk_info = {
                "index": i,
                "text": chunk,
                "keywords": keywords,
                "char_count": len(chunk)
            }
            chunk_data["chunks"].append(chunk_info)

        # 保存到文件
        output_file = chunks_dir / f"{doc_id}.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(chunk_data, f, indent=2, ensure_ascii=False)

        print(f"[INFO] Saved {len(chunks)} chunks to {output_file.name}")

        success_count += 1
        doc['indexed'] = True

    # 保存更新后的索引
    index_data['indexed'] = success_count
    index_data['pending'] = index_data['total'] - success_count
    index_data['storage'] = 'text'

    with open(INDEX_FILE, 'w', encoding='utf-8') as f:
        json.dump(index_data, f, indent=2, ensure_ascii=False)

    print(f"\n" + "=" * 60)
    print(f"[SUCCESS] Vectorized {success_count}/{len(docs)} documents")
    print(f"[INFO] Storage: Text-based with keyword index")
    print(f"[INFO] Location: {chunks_dir}")
    print("=" * 60)


if __name__ == "__main__":
    main()
