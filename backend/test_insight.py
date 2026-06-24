import asyncio
from app.services.ai_service import generate_daily_insight

async def test():
    insight = await generate_daily_insight("TestUser", [{"mood": "happy"}], [{"question": "Q1", "answer": "A1"}], [])
    print("INSIGHT:", insight)

if __name__ == "__main__":
    asyncio.run(test())
