from typing import Optional, List
from pydantic import Field
from .auth import BaseSchema

class QuestionOut(BaseSchema):
    id: int
    day_number: int
    question_type: str
    question_text: str
    scenario_prefix: Optional[str] = None
    hint_text: Optional[str] = None
    category_name: Optional[str] = None

class TodayQuestionResponse(BaseSchema):
    success: bool = True
    session_id: int
    day_number: int
    question: QuestionOut
    is_completed: bool = False
    is_missed_day: bool = False

class AnswerRequest(BaseSchema):
    session_id: int
    question_id: int
    text_answer: str = Field(..., max_length=5000)

class AIReaction(BaseSchema):
    emotion_detected: str
    tone: str
    reaction_text: str

class AnswerResponse(BaseSchema):
    success: bool = True
    answer_id: int
    ai_reaction: AIReaction
    is_completed: bool = False

class TodayStatusResponse(BaseSchema):
    success: bool = True
    day_number: int
    user_completed: bool
    partner_completed: bool = False
    user_total_completed: int = 0
    partner_total_completed: int = 0
    shared_days_completed: int = 0

class SessionHistoryItem(BaseSchema):
    session_id: int
    day_number: int
    is_completed: bool
    completed_at: Optional[str] = None
