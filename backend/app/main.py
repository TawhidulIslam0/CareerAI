from fastapi import FastAPI,UploadFile,File,Request,HTTPException
from fastapi.middleware.cors import CORSMiddleware
import httpx
from .config import OLLAMA_BASE_URL,OLLAMA_MODEL,MAX_UPLOAD_MB,CORS_ORIGINS
from .schemas import TextReq,ImproveReq,LetterReq,InterviewReq
from .documents import extract,ats
from .ai import generate,AIError
from .limiter import limit
app=FastAPI(title="CareerAI local backend",version="0.1.0")
app.add_middleware(CORSMiddleware,allow_origins=CORS_ORIGINS,allow_credentials=False,allow_methods=["*"],allow_headers=["*"])
def fail(e): raise HTTPException(503,str(e))
@app.get("/")
def root():return {"name":"CareerAI","docs":"/docs","health":"/health"}
@app.get("/health")
async def health():
 try:
  async with httpx.AsyncClient(timeout=3) as c:r=await c.get(OLLAMA_BASE_URL+"/api/tags"); tags=r.json().get("models",[]) if r.is_success else []
  connected=r.is_success; found=any(m.get("name","").startswith(OLLAMA_MODEL) for m in tags)
 except Exception:connected=False;found=False
 return {"status":"ok","ollama":connected,"model":OLLAMA_MODEL,"model_ready":found}
@app.post("/resume/upload")
async def upload(req:Request,file:UploadFile=File(...)):
 limit(req)
 if not file.filename or not file.filename.lower().endswith((".pdf",".docx")):raise HTTPException(400,"PDF/DOCX only")
 data=await file.read(MAX_UPLOAD_MB*1024*1024+1)
 if len(data)>MAX_UPLOAD_MB*1024*1024:raise HTTPException(413,"Upload too large")
 try:t=extract(file.filename,data)
 except Exception as e:raise HTTPException(400,str(e))
 if len(t)<20:raise HTTPException(422,"Text extraction yielded little content; scanned PDFs may need OCR.")
 return {"filename":file.filename,"resume_text":t}
@app.post("/resume/ats")
def atsroute(x:TextReq,req:Request):limit(req);return ats(x.resume_text,x.job_description)
@app.post("/resume/analyze")
async def analyze(x:TextReq,req:Request):
 limit(req); rules=ats(x.resume_text,x.job_description)
 try:a=await generate(f"Analyze resume: structure, strengths, gaps, ATS readability and practical suggestions. Do not promise ATS success. Resume:\n{x.resume_text}\nJob description:\n{x.job_description}")
 except AIError as e:fail(e)
 return {"rules":rules,"analysis":a}
@app.post("/resume/improve")
async def improve(x:ImproveReq,req:Request):
 limit(req)
 try:r=await generate(f"Improve section {x.section} while preserving all facts. No invented claims. Ask questions for missing details. Original:\n{x.resume_text}")
 except AIError as e:fail(e)
 return {"improved_text":r}
@app.post("/jobs/match")
async def match(x:TextReq,req:Request):
 limit(req);rule=ats(x.resume_text,x.job_description)
 try:a=await generate(f"Compare resume to job. List strengths supported by resume, skill gaps, tailoring suggestions, interview topics. Do not recommend claiming unsupported skills. Resume:\n{x.resume_text}\nJob:\n{x.job_description}")
 except AIError as e:fail(e)
 return {"keyword_score":rule["heuristic_score"],"keywords_found":rule["keyword_matches"],"keyword_gaps":rule["keyword_gaps"],"analysis":a}
@app.post("/cover-letter/generate")
async def cover(x:LetterReq,req:Request):
 limit(req)
 try:r=await generate(f"Write tailored cover letter; no fabricated facts. Company {x.company}, role {x.role}. Resume:\n{x.resume_text}\nJob description:\n{x.job_description}\nNotes:{x.extra}")
 except AIError as e:fail(e)
 return {"cover_letter":r}
@app.post("/interview/questions")
async def questions(x:InterviewReq,req:Request):
 limit(req)
 try:r=await generate(f"Generate eight interview practice questions, behavioral and role-related. Resume:\n{x.resume_text}\nJob:\n{x.job_description}")
 except AIError as e:fail(e)
 return {"questions":r}
@app.post("/interview/feedback")
async def feedback(x:InterviewReq,req:Request):
 limit(req)
 try:r=await generate(f"Give answer feedback on clarity, STAR structure, specificity and relevance. Do not invent user's experience. Question:{x.question} Answer:{x.answer} Resume:{x.resume_text}")
 except AIError as e:fail(e)
 return {"feedback":r}
