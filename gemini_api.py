import os
import google.generativeai as genai
from prompts import build_prompt
from dotenv import load_dotenv

# Configure Gemini
load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise EnvironmentError("GEMINI_API_KEY not found in environment variables.")
genai.configure(api_key=api_key)
model = genai.GenerativeModel("gemini-2.0-flash")

def get_medical_analysis(symptom_text):
    prompt = build_prompt(symptom_text)
    try:
        response = model.generate_content(prompt)
        if response and hasattr(response, "text") and response.text:
            return parse_response(response.text)
        else:
            raise ValueError("No valid response from Gemini.")
    except Exception as e:
        raise RuntimeError(f"Gemini API call failed: {e}")

def parse_response(text):
    try:
        lines = [line.strip() for line in text.strip().splitlines() if line.strip()]
        summary = next((line.replace("Symptom Summary:", "").strip() for line in lines if "Symptom Summary:" in line), "")
        conditions = next((line.replace("Likely Conditions:", "").strip() for line in lines if "Likely Conditions:" in line), "")
        specialist = next((line.replace("Recommended Specialist:", "").strip() for line in lines if "Recommended Specialist:" in line), "")
        if not (summary and conditions and specialist):
            raise ValueError("Incomplete response from Gemini.")
        return summary, conditions, specialist
    except Exception as e:
        raise ValueError(f"Error parsing Gemini response: {e}")
