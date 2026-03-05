# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projects

This home directory contains two AI/ML projects:

- **`make-data/`** — RAG pipeline for Korean construction equipment regulations
- **`ai_study/`** — YOLOv8 object detection experiments

---

## make-data: RAG Pipeline

### Commands

All commands must be run from `make-data/` with the `.venv` activated:

```bash
cd make-data
source .venv/bin/activate

make ingest          # Full re-ingestion: scan docs/ → chunk → embed → upload to Qdrant
make dry             # Dry run: count PDFs only, no ingestion
python test_query.py # Run a test RAG query against the vector store
```

### External Service Dependencies

- **Qdrant** — must be running on `localhost:6333` before ingestion or querying
  - Local storage at `make-data/qdrant_db/`
  - Collection name: `construction_laws` (see `config.json`)
- **Ollama** — runs on the WSL host at `http://172.29.224.1:11434`
  - Model configured via `OLLAMA_MODEL` in `.env` (currently `qwen2.5:7b`)

### Architecture

**Data flow:** `docs/{category}/*.pdf` → PyPDFLoader → text cleaning → RecursiveCharacterTextSplitter → HuggingFace embeddings → Qdrant

**Key files:**
- `ingest_to_qdrant.py` — core ingestion logic; exposes `run_integrated_ingestion()`
- `run_pipeline.py` — CLI wrapper that calls `run_integrated_ingestion()`
- `test_query.py` — builds the full RAG chain (retriever + Ollama LLM) and runs a sample query
- `config.json` — Qdrant connection and collection settings
- `.env` — `OLLAMA_BASE_URL` and `OLLAMA_MODEL`

**Chunking strategy:** chunk_size=600, overlap=120, separators ordered `["\n\n", "\n", ". ", " ", ""]`

**Embeddings:** `sentence-transformers/all-MiniLM-L6-v2` (384 dimensions). Note: `config.json` has a `text-embedding-3-small` entry under `embedding.model`, but the actual code hardcodes the HuggingFace model.

**Document metadata** enriched per chunk: `category` (subdirectory name under `docs/`), `source_file`, `full_path`, `page`, `chunk_index`, `char_count`. Chunks shorter than 30 characters are discarded.

**Ingestion is destructive** — `run_integrated_ingestion()` deletes and recreates the Qdrant collection on every run.

**RAG chain** in `test_query.py`: retriever returns top-3 docs → Korean expert prompt → Ollama LLM → string output.
