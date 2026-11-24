import os
from dotenv import load_dotenv
load_dotenv()
OLLAMA_BASE_URL=os.getenv("OLLAMA_BASE_URL","http://127.0.0.1:11434").rstrip("/")
OLLAMA_MODEL=os.getenv("OLLAMA_MODEL","qwen3:8b")
MAX_UPLOAD_MB=int(os.getenv("MAX_UPLOAD_MB","12"))
RATE_LIMIT_PER_MINUTE=int(os.getenv("RATE_LIMIT_PER_MINUTE","20"))
DAILY_REQUEST_LIMIT=int(os.getenv("DAILY_REQUEST_LIMIT","250"))
CORS_ORIGINS=[s.strip() for s in os.getenv("CORS_ORIGINS","*").split(",")]
