from io import BytesIO
from pathlib import Path
from pypdf import PdfReader
from docx import Document

def extract(name, data):
    ext = Path(name).suffix.lower()
    if ext == '.pdf':
        return '\n'.join(page.extract_text() or '' for page in PdfReader(BytesIO(data)).pages).strip()
    if ext == '.docx':
        return '\n'.join(paragraph.text for paragraph in Document(BytesIO(data)).paragraphs).strip()
    raise ValueError('Please upload a PDF or DOCX file.')

def ats(text, job=''):
    lower = text.lower()
    words = text.split()
    checks = [
        ('Contact details', '@' in lower or 'linkedin' in lower or 'phone' in lower),
        ('Summary', any(k in lower for k in ('summary', 'profile', 'objective'))),
        ('Experience', any(k in lower for k in ('experience', 'employment', 'work history'))),
        ('Education', 'education' in lower),
        ('Skills', 'skills' in lower),
        ('Bullet points', any(line.strip().startswith(('-', '•', '*')) for line in text.splitlines())),
        ('Readable length', 250 <= len(words) <= 1200),
    ]
    job_words = {w.strip('.,:;!?()[]{}') for w in job.lower().split() if len(w) >= 4}
    resume_words = {w.strip('.,:;!?()[]{}') for w in lower.split()}
    return {'word_count': len(words), 'checks': [{'label': k, 'passed': v} for k, v in checks],
            'heuristic_score': round(sum(v for _, v in checks) * 100 / len(checks)),
            'keyword_matches': sorted(job_words & resume_words)[:50],
            'keyword_gaps': sorted(job_words - resume_words)[:50],
            'note': 'Heuristic checklist, not ATS guarantee.'}
