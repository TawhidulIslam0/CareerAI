import httpx
from .config import OLLAMA_BASE_URL,OLLAMA_MODEL
class AIError(Exception):pass
async def generate(prompt):
 try:
  async with httpx.AsyncClient(timeout=180) as c:
   r=await c.post(OLLAMA_BASE_URL+"/api/generate",json={"model":OLLAMA_MODEL,"prompt":guard(prompt),"stream":False,"options":{"temperature":0.3}}); r.raise_for_status(); return r.json().get("response","").strip()
 except httpx.HTTPError as e: raise AIError(f"Ollama unavailable/model error: {e}. Check Ollama and model setting.")
def guard(p):return "Act as careful career coach. Never invent user facts, employers, dates, metrics, credentials, skills or accomplishments. Missing facts must be questions or clearly labeled placeholders. Use provided source facts only.\n\n"+p
