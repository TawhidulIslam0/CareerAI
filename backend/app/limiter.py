from collections import defaultdict,deque
from datetime import date
from time import time
from fastapi import Request,HTTPException
from .config import RATE_LIMIT_PER_MINUTE,DAILY_REQUEST_LIMIT
hits=defaultdict(deque); daily=defaultdict(int); day=date.today()
def limit(req:Request):
 global day,daily
 ip=req.client.host if req.client else "unknown"; now=time(); q=hits[ip]
 while q and now-q[0]>60:q.popleft()
 if len(q)>=RATE_LIMIT_PER_MINUTE: raise HTTPException(429,"Minute request limit reached; wait and retry.")
 if date.today()!=day: day=date.today(); daily=defaultdict(int)
 if daily[ip]>=DAILY_REQUEST_LIMIT: raise HTTPException(429,"Daily development limit reached.")
 q.append(now); daily[ip]+=1
