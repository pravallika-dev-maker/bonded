import asyncio
from app.services.ai_service import analyze_answer

async def test():
    print("Testing Gemini AI Integration...")
    
    question = "What do you want to improve in this relationship?"
    answer = "I want to listen more before reacting. I know I make her feel unheard."
    
    print(f"\nQuestion: {question}")
    print(f"User Answer: {answer}")
    print("\nSending to Gemini API... Please wait...")
    
    try:
        response = await analyze_answer(question, answer)
        print("\n✅ SUCCESS! Gemini responded:")
        print(f"Emotion Detected: {response.get('emotion_detected')}")
        print(f"Tone: {response.get('tone')}")
        print(f"Reaction Text: {response.get('reaction_text')}")
    except Exception as e:
        print(f"\n❌ FAILED: {e}")

if __name__ == "__main__":
    asyncio.run(test())
