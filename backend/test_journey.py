import asyncio
import os
import sys
from datetime import date, datetime, timedelta, timezone
from dotenv import load_dotenv

sys.stdout.reconfigure(encoding='utf-8')

# Ensure backend directory is in python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

load_dotenv()

from app.database import SessionLocal, Base, engine
from app.models.user import User
from app.models.separation import Separation
from app.models.mood import Mood
from app.models.letter import Letter
from app.models.reflection_question import ReflectionQuestion
from app.models.reflection_session import ReflectionSession
from app.models.reflection_answer import ReflectionAnswer
from app.api.v1.journey import calculate_user_score, get_love_word
from app.services.ai_service import generate_journey_insights

async def main():
    print("--- STARTING JOURNEY FEATURE TEST ---")
    db = SessionLocal()
    
    # 1. Clean up any leftover test data
    phone_a = "+19998887777"
    phone_b = "+19998887778"
    
    def cleanup_test_data(db_session):
        users = db_session.query(User).filter(User.phone_number.in_([phone_a, phone_b])).all()
        u_ids = [u.id for u in users]
        if u_ids:
            db_session.query(Mood).filter(Mood.user_id.in_(u_ids)).delete(synchronize_session=False)
            db_session.query(Letter).filter((Letter.author_id.in_(u_ids)) | (Letter.partner_id.in_(u_ids))).delete(synchronize_session=False)
            db_session.query(ReflectionAnswer).filter(ReflectionAnswer.user_id.in_(u_ids)).delete(synchronize_session=False)
            db_session.query(ReflectionSession).filter(ReflectionSession.user_id.in_(u_ids)).delete(synchronize_session=False)
            db_session.query(Separation).filter((Separation.creator_id.in_(u_ids)) | (Separation.partner_id.in_(u_ids))).delete(synchronize_session=False)
            db_session.commit()
            for u in users:
                u.partner_id = None
            db_session.commit()
            db_session.query(User).filter(User.id.in_(u_ids)).delete(synchronize_session=False)
            db_session.commit()

    cleanup_test_data(db)
    
    try:
        # 2. Create Test Users (A and B)
        print("Creating User A and User B...")
        user_a = User(
            phone_number=phone_a,
            user_name="Priya",
            relation_type="Married",
            partner_name="Mihail",
            is_partnered=True,
            gender="female",
            relationship_score=0
        )
        user_b = User(
            phone_number=phone_b,
            user_name="Mihail",
            relation_type="Married",
            partner_name="Priya",
            is_partnered=True,
            gender="male",
            relationship_score=0
        )
        db.add(user_a)
        db.add(user_b)
        db.commit()
        db.refresh(user_a)
        db.refresh(user_b)
        
        # Link partners
        user_a.partner_id = user_b.id
        user_b.partner_id = user_a.id
        db.commit()
        print(f"Users created! User A (id={user_a.id}), User B (id={user_b.id}) are connected.")
        
        # 3. Create active separation
        print("Creating active separation...")
        start_date = date.today() - timedelta(days=6) # Started 6 days ago (so day_number = 7 today)
        expected_end_date = start_date + timedelta(days=7) # Ending today
        
        separation = Separation(
            creator_id=user_a.id,
            partner_id=user_b.id,
            duration_label="1 week",
            start_date=start_date,
            expected_end_date=expected_end_date,
            reason="Taking time to reflect and breathe",
            status="active"
        )
        db.add(separation)
        db.commit()
        db.refresh(separation)
        print(f"Separation created! ID={separation.id}, Start Date={start_date}, Expected End Date={expected_end_date}")
        
        # 4. Check if questions exist, seed a default one for Day 7 (day_number=7)
        question = db.query(ReflectionQuestion).filter(ReflectionQuestion.day_number == 7).first()
        if not question:
            print("Seeding temporary ReflectionQuestion for Day 7...")
            question = ReflectionQuestion(
                day_number=7,
                question_type="text",
                question_text="What would happen if you shared your biggest fear today?",
                is_active=True
            )
            db.add(question)
            db.commit()
            db.refresh(question)
        
        # 5. Add Reflection Session and Answer for User A
        print("Adding reflection session and answer for User A...")
        session_a = ReflectionSession(
            user_id=user_a.id,
            separation_id=separation.id,
            day_number=7,
            is_completed=True,
            completed_at=datetime.now(timezone.utc)
        )
        db.add(session_a)
        db.commit()
        db.refresh(session_a)
        
        answer_a = ReflectionAnswer(
            session_id=session_a.id,
            user_id=user_a.id,
            question_id=question.id,
            text_answer="My biggest fear is that we will grow apart and stop understanding each other's silence.",
            ai_emotion_detected="fearful",
            ai_tone="reflective",
            ai_reaction_text="That takes deep courage to admit.",
            ai_processed=True
        )
        db.add(answer_a)
        db.commit()
        
        # 6. Add Reflection Session and Answer for User B
        print("Adding reflection session and answer for User B...")
        session_b = ReflectionSession(
            user_id=user_b.id,
            separation_id=separation.id,
            day_number=7,
            is_completed=True,
            completed_at=datetime.now(timezone.utc)
        )
        db.add(session_b)
        db.commit()
        db.refresh(session_b)
        
        answer_b = ReflectionAnswer(
            session_id=session_b.id,
            user_id=user_b.id,
            question_id=question.id,
            text_answer="I fear that I don't give Priya the emotional safety she needs to speak open-heartedly.",
            ai_emotion_detected="love",
            ai_tone="warm",
            ai_reaction_text="Observing that within yourself shows incredible wisdom.",
            ai_processed=True
        )
        db.add(answer_b)
        db.commit()
        
        # 7. Add Moods
        print("Logging mock moods...")
        mood_a1 = Mood(user_id=user_a.id, mood="peaceful")
        mood_a2 = Mood(user_id=user_a.id, mood="hopeful")
        mood_b1 = Mood(user_id=user_b.id, mood="grateful")
        db.add(mood_a1)
        db.add(mood_a2)
        db.add(mood_b1)
        db.commit()
        
        # 8. Add Letters
        print("Writing a mock letter...")
        letter_a = Letter(
            author_id=user_a.id,
            partner_id=user_b.id,
            title="A quiet note",
            content="I am writing this to say that I miss you, but I'm grateful for this breathing space.",
            ai_love_score=85,
            is_revealed=True
        )
        db.add(letter_a)
        db.commit()
        
        # 9. Test calculate_user_score
        print("\n--- Testing score calculation logic ---")
        score = calculate_user_score(db, user_a)
        love_info = get_love_word(score)
        print(f"User A Score: {score}")
        print(f"User A Love Status Word: {love_info['loveWord']} {love_info['emoji']}")
        print(f"Message: {love_info['message']}")
        
        # 10. Test AI journey insights generation
        print("\n--- Requesting AI Journey Insights from Gemini ---")
        print("Preparing bundle data...")
        
        # Structure payload just like journey.py GET /insights does:
        user_ref_data = [
            {
                "question": question.question_text,
                "answer": answer_a.text_answer,
                "emotion": answer_a.ai_emotion_detected,
                "tone": answer_a.ai_tone
            }
        ]
        partner_ref_data = [
            {
                "question": question.question_text,
                "answer": answer_b.text_answer,
                "emotion": answer_b.ai_emotion_detected,
                "tone": answer_b.ai_tone
            }
        ]
        
        bundle_data = {
            "partner_a_reflections": user_ref_data,
            "partner_b_reflections": partner_ref_data,
            "partner_a_moods": ["peaceful", "hopeful"],
            "partner_b_moods": ["grateful"],
            "shared_days": 1,
            "partner_a_total_days": 1,
            "partner_b_total_days": 1,
            "partner_a_letters": 1,
            "partner_b_letters": 0
        }
        
        print("Calling Gemini API...")
        insights = await generate_journey_insights(user_a.user_name, user_b.user_name, bundle_data)
        
        print("\n✅ AI INSIGHTS GENERATION SUCCESSFUL:")
        import json
        print(json.dumps(insights, indent=2))
        
    except Exception as e:
        print(f"❌ TEST FAILED: {e}")
        import traceback
        traceback.print_exc()
        
    finally:
        # 11. Cleanup test records
        print("\nCleaning up test records from database...")
        cleanup_test_data(db)
        db.close()
        print("✅ Cleanup complete. Database left in original state.")

if __name__ == "__main__":
    asyncio.run(main())
