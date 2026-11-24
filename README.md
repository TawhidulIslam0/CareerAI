# CareerAI Flutter + local Ollama

Flutter/Dart Android app and FastAPI backend. AI calls go to Ollama running on your PC; no paid AI API.

## Included features
Resume upload (PDF/DOCX), resume analysis/improvement, heuristic ATS checks, job matching, cover letters, interview questions/answer feedback, editable resume and PDF export, local application tracker, saved resume/tracker/history in Hive, backend settings, rate limits, upload limits, Google Play Billing scaffold and pricing screen ($4.99/month, $14.99 lifetime; purchases not enabled yet).

## Setup (Windows PowerShell)
Ollama is already installed, so verify/download the model if needed:
`ollama list` and `ollama pull qwen3:8b` (only if missing).

Backend:
```powershell
cd backend
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
Test http://127.0.0.1:8000/health and /docs.

Android:
```powershell
cd android_app
# Generate the native Android/Gradle wrapper using your installed Flutter SDK
# (the source package includes Android entry point; Flutter CLI generates SDK-specific scaffolding)
flutter create . --platforms android --overwrite
flutter pub get
flutter doctor
flutter run
```
Default emulator backend is `http://10.0.2.2:8000`. On a physical phone on the same Wi-Fi, set Settings backend URL to your PC IPv4 from `ipconfig`, e.g. `http://192.168.x.x:8000`.

## Architecture
`android_app/lib`: screens, models, services, utilities, widgets. `backend/app`: API, Ollama service, document parsing, ATS rules, request throttling. Data is local on the phone; no cloud accounts/sync in this version. Backend throttling is in-memory and dev-only. Do not expose this server to the internet without auth, HTTPS, durable rate limits, and server-side purchase verification. Billing scaffold is not yet purchase-enabled. Resume facts should be reviewed; AI is advisory.

## Roadmap / configuration-only items
- Firebase Authentication + cloud resume/application sync: not activated in this local-first build. Set up a Firebase project, enable auth providers, configure Android app package `com.careerai.app`, then add Firebase Flutter packages/config files and security rules.
- Google Play Billing: package dependency and plan display are included, but no purchases/entitlements are active. Create product IDs in Play Console, configure product IDs, implement purchase verification on a trusted server, and use Play license testing before release.
- Public hosting: no server deployment configuration is enabled; public deployment requires an operator-managed host, TLS, authentication, privacy safeguards, and cost planning. Local Ollama is not suitable as a public production service.
- Security: dev IP throttling and upload caps exist. For launch replace in-memory quotas with shared persistent storage, add authentication, access control, secure secrets, logging/monitoring, and request validation.
