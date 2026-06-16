import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import Base
from app.models.question_category import QuestionCategory
from app.models.reflection_question import ReflectionQuestion
from dotenv import load_dotenv

load_dotenv()
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")
if not SQLALCHEMY_DATABASE_URL:
    SQLALCHEMY_DATABASE_URL = "postgresql://postgres:postgre@localhost:5432/bonded_db"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def seed_db():
    print("Creating tables if they don't exist...")
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        # 1. Categories
        if db.query(QuestionCategory).count() == 0:
            print("Seeding Question Categories...")
            categories = [
                QuestionCategory(id=1, name='Memory & Connection', description='Moments that still hold warmth', color_hex='#8A2E55', sort_order=1),
                QuestionCategory(id=2, name='Missing & Absence', description='What the distance is teaching you', color_hex='#9E7E5A', sort_order=2),
                QuestionCategory(id=3, name='Self Reflection', description='Understanding your own patterns', color_hex='#6A5A8E', sort_order=3),
                QuestionCategory(id=4, name='Appreciation', description='Seeing their value more clearly', color_hex='#4A7A5A', sort_order=4),
                QuestionCategory(id=5, name='Hope & Future', description='What you want your relationship to be', color_hex='#911746', sort_order=5),
                QuestionCategory(id=6, name='Deep Emotional', description='What lives quietly in your heart', color_hex='#C97A5A', sort_order=6),
                QuestionCategory(id=7, name='Situational Reflection', description='Learning through others stories', color_hex='#5A7A8E', sort_order=7)
            ]
            db.add_all(categories)
            db.commit()

        # 2. Questions
        if db.query(ReflectionQuestion).count() == 0:
            print("Seeding Reflection Questions...")
            questions = [
                # Day 1: Memory & Connection
                (1, 1, 'text', 'What is your happiest memory together?', None, 'Take a moment to remember...'),
                # Day 2: Missing & Absence
                (2, 2, 'text', 'What feels different in your day without them?', None, 'Be honest with yourself...'),
                # Day 3: Self Reflection
                (3, 3, 'text', 'What do you wish you handled more gently?', None, 'Speak your heart...'),
                # Day 4: Appreciation
                (4, 4, 'text', 'What do you admire most about your partner?', None, 'Think of a specific quality...'),
                # Day 5: Hope & Future
                (5, 5, 'text', 'How do you want your relationship to feel after this break?', None, 'Imagine the best version...'),
                # Day 6: Deep Emotional
                (6, 6, 'text', 'What feeling stayed in your heart today?', None, 'What is really there...'),
                # Day 7: Situational Reflection
                (7, 7, 'situational', 'If you were in this situation, what would you do first?', 'Your friend says: "My partner became silent after our argument."', 'What would be your first step...'),
                # Day 8: Memory & Connection
                (8, 1, 'text', 'What small thing about them do you miss today?', None, 'Even the tiniest detail counts...'),
                # Day 9: Missing & Absence
                (9, 2, 'text', 'At what moment today did you think about them most?', None, 'Walk through your day...'),
                # Day 10: Self Reflection
                (10, 3, 'text', 'What do you understand better now?', None, 'What has this space revealed...'),
                # Day 11: Appreciation
                (11, 4, 'text', 'What effort from them did you notice only after distance?', None, 'Think carefully...'),
                # Day 12: Hope & Future
                (12, 5, 'text', 'What kind of conversation do you hope to have when this ends?', None, 'Picture that moment...'),
                # Day 13: Deep Emotional
                (13, 6, 'text', 'What silence between you feels unfinished?', None, 'What was never said...'),
                # Day 14: Situational Reflection
                (14, 7, 'situational', 'If this was your relationship, how would you handle it?', 'Someone says: "I expect my partner to understand me without explaining."', 'What would you do differently...'),
                # Day 15: Memory & Connection
                (15, 1, 'text', 'What moment with them still makes you smile?', None, 'Let yourself go back there...'),
                # Day 16: Missing & Absence
                (16, 2, 'text', 'What do you wish you could tell them right now?', None, 'Say it here, safely...'),
                # Day 17: Self Reflection
                (17, 3, 'text', 'What expectation did you never express clearly?', None, 'Be honest with yourself...'),
                # Day 18: Appreciation
                (18, 4, 'text', 'What is one thing they always did for you?', None, 'Something they did consistently...'),
                # Day 19: Hope & Future
                (19, 5, 'text', 'What would make your relationship feel more peaceful?', None, 'Dream a little...'),
                # Day 20: Deep Emotional
                (20, 6, 'text', 'What do you think your partner never understood about you?', None, 'What was always missed...'),
                # Day 21: Situational Reflection
                (21, 7, 'situational', 'If you were one of them, what would you try to change?', 'Your friend says: "We love each other, but we still hurt each other often."', 'What change would matter most...'),
                # Day 22: Memory & Connection
                (22, 1, 'text', 'What place reminds you of your partner the most?', None, 'Where does your mind go...'),
                # Day 23: Missing & Absence
                (23, 2, 'text', 'What part of your routine feels empty today?', None, 'Notice the small gaps...'),
                # Day 24: Self Reflection
                (24, 3, 'text', 'What do you think your partner needed from you most?', None, 'What did they ask for...'),
                # Day 25: Appreciation
                (25, 4, 'text', 'What quality of theirs makes you feel calm?', None, 'What settles you about them...'),
                # Day 26: Hope & Future
                (26, 5, 'text', 'What does a healthy relationship mean to you now?', None, 'How has your view changed...'),
                # Day 27: Deep Emotional
                (27, 6, 'text', 'What do you think you never understood about them?', None, 'Look at them from their side...'),
                # Day 28: Situational Reflection
                (28, 7, 'situational', 'How would you feel if this happened to you?', 'Someone says: "I only realized my partner\'s value after distance."', 'What would that feel like...'),
                # Day 29: Memory & Connection
                (29, 1, 'text', 'What is one ordinary moment with them that now feels special?', None, 'The simple things...'),
                # Day 30: Missing & Absence
                (30, 2, 'text', 'What do you miss more than you expected?', None, 'What surprised you...'),
                # Day 31: Self Reflection
                (31, 3, 'text', 'What would you do differently in your next conversation?', None, 'Picture the conversation...'),
                # Day 32: Appreciation
                (32, 4, 'text', 'What made you feel loved by them?', None, 'How did their love show up...'),
                # Day 33: Hope & Future
                (33, 5, 'text', 'What is one change that could bring you both closer?', None, 'Just one honest thing...'),
                # Day 34: Deep Emotional
                (34, 6, 'text', 'What moment made you realize they matter deeply to you?', None, 'When did you truly know...'),
                # Day 35: Situational Reflection
                (35, 7, 'situational', 'If you felt emotionally unheard, what would you do?', 'Your friend says: "I stopped expressing my feelings because I felt unheard."', 'What would be your response...'),
                # Day 36: Memory & Connection
                (36, 1, 'text', 'What was the last moment you felt truly close to them?', None, 'Go back to that feeling...'),
                # Day 37: Missing & Absence
                (37, 2, 'text', 'What feeling became stronger during this silence?', None, 'What grew in the quiet...'),
                # Day 38: Self Reflection
                (38, 3, 'text', 'What have you learned about yourself during this break?', None, 'What did space reveal...'),
                # Day 39: Appreciation
                (39, 4, 'text', 'What is one thing they do better than anyone else?', None, 'Their unique gift...'),
                # Day 40: Hope & Future
                (40, 5, 'text', 'What do you want your partner to feel more often?', None, 'What would you give them...'),
                # Day 41: Deep Emotional
                (41, 6, 'text', 'What hurt stayed with you quietly?', None, 'The thing you carry silently...'),
                # Day 42: Situational Reflection
                (42, 7, 'situational', 'If you were in this situation, how would you express your pain better?', 'Someone says: "I become angry when I actually feel hurt."', 'What would healthier expression look like...'),
                # Day 43: Memory & Connection
                (43, 1, 'text', 'What song reminds you of your relationship?', None, 'What does it bring up...'),
                # Day 44: Missing & Absence
                (44, 2, 'text', 'What small message from them would make you smile today?', None, 'Just one line...'),
                # Day 45: Self Reflection
                (45, 3, 'text', 'What feeling do you usually hide during arguments?', None, 'What is underneath the reaction...'),
                # Day 46: Appreciation
                (46, 4, 'text', 'What is something about them you never appreciated enough?', None, 'What did you overlook...'),
                # Day 47: Hope & Future
                (47, 5, 'text', 'What kind of memories do you want to create together later?', None, 'Dream forward...'),
                # Day 48: Deep Emotional
                (48, 6, 'text', 'What love language do you think they express naturally?', None, 'How do they show love...'),
                # Day 49: Situational Reflection
                (49, 7, 'situational', 'If this happened in your relationship, what would you change?', 'Your friend says: "I wait for effort, but I never clearly express my expectations."', 'What would you do differently...'),
                # Day 50: Memory & Connection
                (50, 1, 'text', 'What habit of theirs do you miss unexpectedly?', None, 'The small things you took for granted...'),
                # Day 51: Missing & Absence
                (51, 2, 'text', 'What did you take for granted before this break?', None, 'Look at what was always there...'),
                # Day 52: Self Reflection
                (52, 3, 'text', 'What makes you pull away emotionally?', None, 'What triggers your distance...'),
                # Day 53: Appreciation
                (53, 4, 'text', 'What memory makes you feel grateful for them?', None, 'One that stays with you...'),
                # Day 54: Hope & Future
                (54, 5, 'text', 'What does emotional safety mean to you?', None, 'What makes you feel safe with someone...'),
                # Day 55: Deep Emotional
                (55, 6, 'text', 'What emotional support from them do you miss?', None, 'What did their presence give you...')
            ]
            q_objs = []
            for day, cat_id, q_type, text, prefix, hint in questions:
                q_objs.append(ReflectionQuestion(
                    day_number=day, category_id=cat_id, question_type=q_type,
                    question_text=text, scenario_prefix=prefix, hint_text=hint
                ))
            db.add_all(q_objs)
            db.commit()
            print("Successfully seeded questions.")
        else:
            print("DB already seeded.")
    except Exception as e:
        print(f"Error seeding DB: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_db()
