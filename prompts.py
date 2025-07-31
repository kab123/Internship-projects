def build_prompt(symptom_text):
    return f"""
You are an intelligent healthcare assistant. A user has reported the following symptoms:

"{symptom_text}"

Please do the following:
1. Summarize the symptoms in clear medical language. Start with "Symptom Summary:"
2. List at least 2-3 potential medical conditions that could explain the symptoms. Be concise, medically accurate, and use common condition names if applicable. Start with "Likely Conditions:"
3. Recommend the appropriate medical specialist. Start with "Recommended Specialist:"

Format:
Symptom Summary: ...
Likely Conditions: ...
Recommended Specialist: ...
"""
