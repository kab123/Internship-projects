import streamlit as st
from gemini_api import get_medical_analysis

st.set_page_config(page_title="AI Symptom Checker", layout="centered")

st.title(" AI-Powered Symptom Checker & Specialist Recommender")

st.markdown("Enter your symptoms in natural language and receive an intelligent medical summary, possible conditions, and a suggested specialist.")

symptom_input = st.text_area("Describe your symptoms:", height=200, placeholder="e.g., I’ve had a sore throat and mild fever for 3 days...")

if st.button("Analyze Symptoms") and symptom_input.strip():
    with st.spinner("Analyzing with Gemini AI..."):
        try:
            summary, conditions, specialist = get_medical_analysis(symptom_input)
            st.success("Analysis Complete!")
            st.subheader("Symptom Summary")
            st.write(summary)
            st.subheader("Likely Conditions")
            st.write(conditions)
            st.subheader("Recommended Specialist")
            st.write(specialist)
        except Exception as e:
            st.error(f"An error occurred: {e}")
