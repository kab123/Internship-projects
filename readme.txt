this application uses Google Gemini to analyze the users symptoms and identifies potential conditions.

Architecture:
the api key for Gemini is needed to use Gemini and it is stored in the .env file and is loaded in gemini_api.py file. the main.py file sets up a basic user interface to input symptoms.
gemini_api.py gets symptoms from main.py and uses gemini to generate a response and parse it using the parse_response def. finally,
the results are displayed in the streamlit UI that main.py writes the response to.

Prompting Stratagy:
I had to evolve the prompts from basic ones to more specific prompts to get a more accurate result.
the more specific the prompt for Gemini the more accurate results will be.

Set up:

open code in PyCharm or python IDE. use terminal to write "streamlit run main.py" without quotes and press enter.