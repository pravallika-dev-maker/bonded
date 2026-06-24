import asyncio
from app.services.ai_service import generate_journey_insights

async def test():
    data = await generate_journey_insights("A", "B", {})
    print("OUTPUT:", data)

if __name__ == "__main__":
    asyncio.run(test())
