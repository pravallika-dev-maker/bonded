import json
import os
import logging
from google import genai
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger("bonded.ai")

# ── Singleton Gemini client ──────────────────────────────────────────────────
_client = None

def _get_client():
    global _client
    if _client is None:
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise RuntimeError("GEMINI_API_KEY environment variable is not set.")
        _client = genai.Client(api_key=api_key)
    return _client


SYSTEM_PROMPT = """You are Bonded — a warm, gentle, and deeply human emotional companion.

A user is going through a separation period with their partner and has just answered a reflection question.
Your role is to read their reflection and respond as a caring, neutral companion.

CRITICAL RULES — you MUST follow these without exception:
- Keep your response strictly to 2–4 short sentences (maximum 50 words).
- Use simple, easy-to-understand language.
- Be warm and deeply human.
- Do NOT use long paragraphs.
- Do NOT use therapy language, clinical terms, or psychological jargon.
- You are NOT the partner. Never speak AS the partner.
- Do NOT continue or complete the user's answer.
- Focus on one simple, gentle insight or comforting thought based on what they shared.

Return ONLY valid JSON:
{
  "reaction_text": "your warm, short, human response here"
}"""

async def analyze_answer(question_text: str, user_answer: str) -> dict:
    client = _get_client()
    prompt = f'{SYSTEM_PROMPT}\n\nReflection Question: "{question_text}"\nUser\'s Answer: "{user_answer}"\n\nRespond as the supportive guide, NOT as the partner.'
    try:
        response = await client.aio.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
        )
        text = response.text.strip().strip("```json").strip("```").strip()
        return json.loads(text)
    except Exception as e:
        logger.error(f"Gemini analyze_answer failed: {e}")
        return {"reaction_text": "Thank you for sharing that. It takes courage to look inward, and every reflection brings you a little more clarity."}


async def generate_mood_insight(mood: str, reflection: str = "") -> dict:
    client = _get_client()

    reflection_context = f'\nThey also wrote: "{reflection}"' if reflection and reflection.strip() else ""

    prompt = f"""You are Bonded AI — warm, emotionally intelligent, and deeply human.

A person going through a relationship separation has just checked in with how they feel.

Their mood right now: "{mood}"{reflection_context}

Based on this, generate:
1. A short, deeply moving emotional QUOTE (1-2 lines, poetic, original — NOT a famous quote, feel original and personal)
2. A gentle, compassionate ADVICE (2-3 sentences) that speaks directly to someone feeling "{mood}" during a separation period

The quote should feel like something written just for them in this moment.
The advice should be warm, non-generic, emotionally aware, and gently guiding — like a wise best friend.

Return ONLY valid JSON:
{{
  "quote": "your original emotional quote here",
  "advice": "your personalized gentle advice here"
}}"""

    try:
        response = await client.aio.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
        )
        text = response.text.strip().strip("```json").strip("```").strip()
        data = json.loads(text)
        return {
            "quote": data.get("quote", ""),
            "advice": data.get("advice", "")
        }
    except Exception as e:
        logger.error(f"Gemini generate_mood_insight failed: {e}")
        fallbacks = {
            "longing": {
                "quote": "The ache of missing someone is love with nowhere to go — hold it gently.",
                "advice": "Longing is a sign of how deeply you care. Let it remind you of what matters, not what's missing."
            },
            "peaceful": {
                "quote": "Peace is not the absence of pain — it is the decision to breathe through it.",
                "advice": "This stillness you feel is earned. Stay in it. You don't have to fix anything today."
            },
            "reflective": {
                "quote": "The questions you sit with today become the clarity you carry tomorrow.",
                "advice": "Something is surfacing within you. Trust the process of looking inward — it's where real answers live."
            },
            "growing": {
                "quote": "Growth is quiet. You won't always feel it — but it's happening.",
                "advice": "Every moment of this separation where you choose awareness over reaction is a step forward. You are becoming."
            },
        }
        return fallbacks.get(mood.lower(), {
            "quote": "Even the hardest seasons leave something beautiful behind.",
            "advice": "Take a breath. You are doing better than you think."
        })


async def generate_comparison_suggestions(summary: list) -> list:
    client = _get_client()
    prompt = f"""Two partners answered the same reflection question separately.
Their answers: {json.dumps(summary, indent=2)}
Generate 3 short, compassionate suggestions for this couple.
Return ONLY JSON array: ["suggestion1", "suggestion2", "suggestion3"]"""
    try:
        response = await client.aio.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
        )
        text = response.text.strip().strip("```json").strip("```").strip()
        return json.loads(text)
    except Exception as e:
        logger.error(f"Gemini generate_comparison_suggestions failed: {e}")
        return ["Showing up every day is already progress."]


async def evaluate_love_letter(letter_content: str) -> int:
    client = _get_client()
    prompt = f"""Read the following letter written by someone to their partner during a separation.
Give it a 'love_score' from 0 to 100 based on how loving, constructive, forgiving, and emotionally safe it is.
- High score (80-100): Full of love, hope, appreciation, taking responsibility, emotional warmth.
- Medium score (40-79): Neutral, confused, or expressing hurt but willing to try.
- Low score (0-39): Blaming, toxic, angry, manipulative, or emotionally unsafe.

Letter: "{letter_content}"

Return ONLY valid JSON:
{{"love_score": 85}}"""
    try:
        response = await client.aio.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
        )
        text = response.text.strip().strip("```json").strip("```").strip()
        data = json.loads(text)
        return data.get("love_score", 0)
    except Exception as e:
        logger.error(f"Gemini evaluate_love_letter failed: {e}")
        return 0

async def generate_journey_insights(current_user_name: str, partner_name: str, data: dict) -> dict:
    client = _get_client()

    prompt = f"""You are BONDED AI, an emotionally intelligent relationship reflection assistant.
Your role is to analyze the complete separation journey of two partners based on their reflections, moods, and letters.
Your goal is NOT to judge, diagnose, criticize, or compare partners.
Your goal is to help both partners understand what strengthens their relationship, emotional needs, growth, communication patterns, and how to reconnect.
Use a warm, compassionate, emotionally mature tone.
Avoid: Harsh language, clinical terminology, blame, taking sides, or guilt.
Always focus on: Understanding, Growth, Empathy, Appreciation, Hope.

COUPLE: {current_user_name} & {partner_name}
(Note: You are speaking directly to {current_user_name}.)

DATA COLLECTED DURING THEIR SEPARATION:
{current_user_name}'s Reflection Answers & Emotions:
{json.dumps(data.get("partner_a_reflections", []), indent=2)}

{partner_name}'s Reflection Answers & Emotions:
{json.dumps(data.get("partner_b_reflections", []), indent=2)}

{current_user_name}'s Mood History: {data.get("partner_a_moods", [])}
{partner_name}'s Mood History: {data.get("partner_b_moods", [])}

Days Both Completed Reflections Together: {data.get("shared_days", 0)}
Total Reflection Days: {current_user_name}: {data.get("partner_a_total_days", 0)}, {partner_name}: {data.get("partner_b_total_days", 0)}
Letters Written: {current_user_name}: {data.get("partner_a_letters", 0)}, {partner_name}: {data.get("partner_b_letters", 0)}

CRITICAL RULES FOR BREVITY & IMPACT:
- The user specifically requested: "make dont too text try to give small small, but clear and usefull".
- Keep every text field EXTREMELY concise. 
- Use 1-2 short sentences maximum per explanation. 
- Use 3-5 word bullet points. 
- Do NOT write long paragraphs. Get straight to the emotional core.

You MUST return ONLY valid JSON in exactly this format, mapping to the 11 steps of the analysis:
{{
  "bondScore": {{
    "score": 85,
    "explanation": "2 short sentences explaining the score based on their emotional openness and growth."
  }},
  "holdsTogether": {{
    "strengths": ["Strength 1 (3-4 words)", "Strength 2", "Strength 3"],
    "explanation": "1 short sentence summary."
  }},
  "trulyMissed": {{
    "missed": ["Missed item 1", "Missed item 2"],
    "interpretation": "1 short sentence emotional interpretation."
  }},
  "unspokenNeeds": {{
    "individual": ["Individual need 1"],
    "shared": ["Shared need 1"],
    "explanation": "1 short sentence explanation."
  }},
  "howYouGrown": {{
    "areas": ["Growth area 1"],
    "examples": "1 short sentence example."
  }},
  "patternsNoticed": {{
    "patterns": ["Pattern 1"],
    "whyItMatters": "1 short sentence why it matters."
  }},
  "quietLove": {{
    "behaviors": ["Behavior 1"],
    "summary": "1 short sentence summary."
  }},
  "leftUnsaid": {{
    "themes": ["Hidden feeling 1"],
    "summary": "1 short sentence summary."
  }},
  "blindSpots": {{
    "opportunities": ["Opportunity 1"],
    "explanation": "1 short sentence explanation."
  }},
  "futureWant": {{
    "alignment": ["Shared hope 1"],
    "summary": "1 short sentence summary."
  }},
  "aiLetter": "A deeply personalized, uplifting, and reflective letter (3-4 short paragraphs, 150 words max). Start with 'Dear {current_user_name},'"
}}"""

    try:
        response = await client.aio.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
        )
        text = response.text.strip().strip("```json").strip("```").strip()
        return json.loads(text)
    except Exception as e:
        logger.error(f"Gemini generate_journey_insights failed: {e}")
        return {
            "bondScore": {"score": 85, "explanation": "You both showed quiet courage and honesty."},
            "holdsTogether": {"strengths": ["Deep emotional care", "Willingness to try"], "explanation": "Your foundation remains strong."},
            "trulyMissed": {"missed": ["Daily presence", "Quiet moments"], "interpretation": "Absence highlighted your deep bond."},
            "unspokenNeeds": {"individual": ["Reassurance"], "shared": ["Emotional safety"], "explanation": "Both of you seek gentle understanding."},
            "howYouGrown": {"areas": ["Patience", "Self-awareness"], "examples": "You chose reflection over reaction."},
            "patternsNoticed": {"patterns": ["Holding back fears"], "whyItMatters": "Vulnerability brings you closer."},
            "quietLove": {"behaviors": ["Showing up daily", "Writing letters"], "summary": "Love was present in the effort."},
            "leftUnsaid": {"themes": ["Fear of disconnect"], "summary": "It's safe to share these now."},
            "blindSpots": {"opportunities": ["Expressing needs sooner"], "explanation": "Don't wait for the 'perfect' moment."},
            "futureWant": {"alignment": ["A peaceful reconnection"], "summary": "You both want the same thing."},
            "aiLetter": f"Dear {current_user_name},\n\nThroughout this separation, you have both shown a courage that is quiet but profound. By taking space to look inward, you've created a landscape where understanding can slowly replace reaction.\n\nTogether, you have honored this time of distance not as a separation, but as a bridge toward clearer, gentler connection.\n\nWith warmth,\nBonded AI"
        }


async def generate_relationship_summary(
    duration_days: int,
    journey_score: int,
    separation_count: int,
    letters_count: int,
    ref_sessions_count: int
) -> str:
    client = _get_client()
    prompt = f"""You are Bonded AI — deeply emotionally intelligent, warm, comforting, and poetic.
A couple has ended their relationship journey. Here is a summary of their metrics:
- Relationship Duration: {duration_days} days
- Final Journey Score: {journey_score}
- Number of Separation Periods: {separation_count}
- Love Letters Exchanged: {letters_count}
- Emotional Reflections Completed: {ref_sessions_count}

Based on these metrics, generate a single, beautiful, and emotionally meaningful relationship summary line. 
It should:
- Speak of the journey with honor, tenderness, and hope.
- Be concise (1-2 sentences, under 30 words).
- Highlight the effort they put in (reflections, letters, and separations) as a testament to their growth, regardless of the relationship ending.
- Never sound robotic, statistical, clinical, or cold. Do not list the raw numbers in the sentence. Instead, translate these numbers into an observation of their shared growth and emotional connection.
- Avoid clichés.

Return ONLY a JSON object with a single key "relationship_summary":
{{
  "relationship_summary": "Your beautiful relationship summary here"
}}"""

    try:
        response = await client.aio.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
        )
        text = response.text.strip().strip("```json").strip("```").strip()
        data = json.loads(text)
        return data.get("relationship_summary", "You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.")
    except Exception as e:
        logger.error(f"Gemini generate_relationship_summary failed: {e}")
        return "You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding."



async def generate_self_insight(mood_logs: list) -> str:
    client = _get_client()
    
    # Format the mood history for the prompt
    history_str = ""
    for idx, log in enumerate(mood_logs):
        note = log.get("reflection") or ""
        history_str += f"- Log {idx+1}: Mood = {log.get('mood')}. Note = \"{note}\"\n"
        
    prompt = f"""You are Bonded AI — deeply emotionally intelligent, warm, comforting, and wise.
A user has logged their moods and short reflections over the past few days.
Analyze their mood history and generate a single, short, personalized insight or characteristic about them (e.g., "You don't express your feelings often" or "You seem more peaceful these days").
The insight should be in second person ("You..."), gentle, observing, and empathetic.
Keep it strictly under 15 words.

Mood History:
{history_str}

Return ONLY a JSON object with a single key "insight":
{{
  "insight": "Your personalized insight here"
}}"""
    try:
        response = await client.aio.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
        )
        text = response.text.strip().strip("```json").strip("```").strip()
        data = json.loads(text)
        return data.get("insight", "You are navigating this season with quiet strength.")
    except Exception as e:
        logger.error(f"Gemini generate_self_insight failed: {e}")
        return "You are navigating this season with quiet strength."

async def generate_daily_affirmation(
    user_name: str,
    in_separation: bool,
    recent_affirmations: list
) -> str:
    client = _get_client()
    
    prompt = f"""Generate a short daily affirmation for a person in a long-distance relationship.

The affirmation should:
* Encourage emotional connection, patience, trust, hope, and resilience.
* Remind the user that meaningful relationships can grow even across distance.
* Inspire them to think warmly about their partner without directly addressing or describing the partner.
* Focus on personal growth, gratitude, emotional well-being, love, and connection.
* Sound like a motivational quote or affirmation, not advice.
* Be uplifting, comforting, and emotionally intelligent.
* Be concise (1-2 sentences, maximum 30 words).
* Use positive and gentle language.
* Avoid clichés, generic relationship tips, and references to breakups, loneliness, sadness, conflict, or insecurity.
* Avoid phrases like "your partner misses you" or assumptions about the partner's feelings.

Examples of the desired style:
* "Distance measures miles, not the strength of a connection. Every shared memory and hopeful thought keeps love moving forward."
* "Some bonds grow strongest in the spaces between moments. Trust the journey and cherish what continues to connect you."
* "Love is not defined by proximity but by presence in the heart. Today's small thoughts can become tomorrow's cherished memories."

AVOID THESE RECENT AFFIRMATIONS (do not generate anything substantially similar):
{json.dumps(recent_affirmations)}

Return ONLY the affirmation text. Do not include quotes around it. Do not return JSON.
"""

    try:
        response = await client.aio.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
        )
        affirmation = response.text.strip().strip('"').strip()
        if affirmation:
            return affirmation
        raise ValueError("Empty affirmation in response")
    except Exception as e:
        logger.error(f"Gemini generate_daily_affirmation failed: {e}")
        return "Distance measures miles, not the strength of a connection."

async def generate_daily_insight(
    user_name: str,
    mood_history: list,
    reflection_history: list,
    recent_insights: list
) -> str:
    client = _get_client()
    
    prompt = f"""You are Bonded AI — an intelligent, analytical, and deeply empathetic relationship coach.
Generate exactly one thoughtful, actionable, and personalized behavioral insight for {user_name}.

DATA TO ANALYZE:
- Recent Moods: {json.dumps(mood_history)}
- Recent Reflections: {json.dumps(reflection_history)}

AVOID THESE RECENT INSIGHTS (do not generate anything substantially similar):
{json.dumps(recent_insights)}

CRITICAL RULES:
- The insight MUST tell the user a specific emotional or behavioral pattern you noticed in their data that will help them.
- Keep it extremely concise: strictly 1 or 2 short sentences. Maximum 30 words.
- Focus immediately on the actionable pattern. Do not write a long, verbose paragraph.
- Speak directly to them ("You...", "A pattern we noticed...").
- Provide a genuine observation, NOT generic motivation.
- It should feel like a brilliant, punchy psychological observation from a highly trained coach.

Examples:
- "A pattern we noticed is that you focus on understanding your partner before expressing your own needs. Giving your emotions equal space will create healthier balance."
- "Your reflections show you process difficult emotions inwardly rather than reacting. This quiet strength is your biggest asset right now."

Return ONLY a JSON object with a single key "insight":
{{
  "insight": "Your insightful observation here"
}}"""

    try:
        response = await client.aio.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
        )
        text = response.text.strip().strip("```json").strip("```").strip()
        data = json.loads(text)
        insight = data.get("insight", "")
        if insight:
            return insight
        raise ValueError("Empty insight in response")
    except Exception as e:
        logger.error(f"Gemini generate_daily_insight failed: {e}")
        
        # Smart fallback if AI fails, based on recent mood
        if mood_history and len(mood_history) > 0:
            latest = mood_history[0]
            mood_val = latest.get("mood", "reflective").lower() if isinstance(latest, dict) else str(latest).lower()
            
            if mood_val in ["sad", "longing", "lonely", "hurt", "angry", "overwhelmed", "anxious"]:
                return f"We notice you've been feeling {mood_val} lately. Allowing yourself to sit with these emotions is a crucial part of the healing process."
            elif mood_val in ["hopeful", "peaceful", "calm", "happy", "relieved", "growing"]:
                return f"Your recent feelings of being {mood_val} show your resilience. You're finding your footing in this space."
            else:
                return f"You've been feeling {mood_val} recently. Checking in with yourself daily builds emotional clarity over time."
                
        return "Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time."

