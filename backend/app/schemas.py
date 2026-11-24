from pydantic import BaseModel, Field
class TextReq(BaseModel):
 resume_text:str=Field(min_length=20,max_length=50000)
 job_description:str=Field(default="",max_length=30000)
 extra:str=Field(default="",max_length=10000)
class ImproveReq(BaseModel):
 resume_text:str=Field(min_length=20,max_length=50000)
 section:str=Field(default="entire resume",max_length=100)
class LetterReq(TextReq):
 company:str=Field(default="",max_length=200)
 role:str=Field(default="",max_length=200)
class InterviewReq(TextReq):
 question:str=Field(default="",max_length=3000)
 answer:str=Field(default="",max_length=10000)
