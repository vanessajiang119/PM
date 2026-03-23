#!/usr/bin/env python3
"""
RAG Vectorization Script
向量化 PDF 文档并存储到 ChromaDB
"""

import os
import sys
import json
import yaml
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


def main():
    print("=" * 60)
    print("RAG Vectorization Script")
    print("=" * 60)

    # 导入依赖
    try:
        import chromadb
        from chromadb.config import Settings
    except ImportError as e:
        print(f"[ERROR] chromadb not installed: {e}")
        print("       pip install chromadb")
        sys.exit(1)

    try:
        from pypdf import PdfReader
    except ImportError as e:
        print(f"[ERROR] pypdf not installed: {e}")
        print("       pip install pypdf")
        sys.exit(1)

    # 加载配置和索引
    config = load_config()
    index_data = load_index()

    print(f"\n[INFO] Config: {config['rag']['name']} v{config['rag']['version']}")
    print(f"[INFO] Total documents: {index_data['total']}")

    # 初始化 ChromaDB
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    chroma_client = chromadb.PersistentClient(
        path=str(DATA_DIR),
        settings=Settings(
            anonymized_telemetry=False,
            allow_reset=True,
        )
    )

    collection_name = config.get('vector_db', {}).get('chroma_config', {}).get('collection_name', 'chip_design')
    collection = chroma_client.get_or_create_collection(
        name=collection_name,
        metadata={"description": "Chip Design RAG Knowledge Base"}
    )

    print(f"[INFO] ChromaDB collection: {collection_name}")

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
        try:
            reader = PdfReader(str(doc_path))
            text = ""
            for page in reader.pages:
                text += page.extract_text() + "\n"
        except Exception as e:
            print(f"[ERROR] Failed to extract text: {e}")
            continue

        if not text.strip():
            print(f"[WARN] No text extracted")
            continue

        print(f"[INFO] Extracted {len(text)} characters")

        # 分块
        chunks = simple_chunk_text(text, chunk_size=2048, overlap=256)
        print(f"[INFO] Created {len(chunks)} chunks")

        if not chunks:
            continue

        # 存储到 ChromaDB
        doc_id = doc['id']
        ids = []
        documents = []
        metadatas = []

        for i, chunk in enumerate(chunks):
            chunk_id = f"{doc_id}_chunk_{i}"
            ids.append(chunk_id)
            documents.append(chunk)
            metadatas.append({
                "agent": doc['agent'],
                "category": doc['category'],
                "filename": doc['filename'],
                "document_id": doc_id,
                "chunk_index": i,
                "total_chunks": len(chunks)
            })

        try:
            collection.add(ids=ids, documents=documents, metadatas=metadatas)
            print(f"[INFO] Stored {len(chunks)} chunks in ChromaDB")
            success_count += 1
            doc['indexed'] = True
        except Exception as e:
            print(f"[ERROR] Failed to store in ChromaDB: {e}")

    # 保存更新后的索引
    index_data['indexed'] = success_count
    index_data['pending'] = index_data['total'] - success_count

    with open(INDEX_FILE, 'w', encoding='utf-8') as f:
        json.dump(index_data, f, indent=2, ensure_ascii=False)

    print(f"\n" + "=" * 60)
    print(f"[SUCCESS] Vectorized {success_count}/{len(docs)} documents")
    print(f"[INFO] Total items in collection: {collection.count()}")
    print("=" * 60)


if __name__ == "__main__":
    main()
