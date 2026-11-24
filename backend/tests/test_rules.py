from app.documents import ats
def test_ats_score_range():
 r=ats("Email: test@example.com\nSummary\nExperience\nSkills\nEducation\n- task")
 assert 0<=r["heuristic_score"]<=100 and isinstance(r["checks"],list)
