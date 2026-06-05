from typing import Optional, List
from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel


class BaseSchema(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
        from_attributes=True,
    )


# ── Question ────────────────────────────────────────────────────────────────

class QuestionOut(BaseSchema):
    id: int
    day_number: int
    question_type: str           # "text" | "situational"
    question_text: str
    scenario_prefix: Optional[str] = None
    hint_text: Optional[str] = None
    category_name: Optional[str] = None


# ── Today's Session ──────────────────────────────────────────────────────────

class TodayQuestionResponse(BaseSchema):
    success: bool = True
    session_id: int
    day_number: int
    question: QuestionOut


# ── Submit one Answer ────────────────────────────────────────────────────────

class AnswerRequest(BaseSchema):
    session_id: int
    question_id: int
    text_answer: str


class AIReaction(BaseSchema):
    emotion_detected: str
    tone: str                   # "healthy" | "warning" | "neutral"
    reaction_text: str


class AnswerResponse(BaseSchema):
    success: bool = True
    answer_id: int
    ai_reaction: AIReaction


# ── Submit day (mark complete) ───────────────────────────────────────────────

class SubmitRequest(BaseSchema):
    session_id: int


class SubmitResponse(BaseSchema):
    success: bool = True
    message: str
    partner_also_completed: bool = False
    comparison_ready: bool = False


# ── Today's Status ───────────────────────────────────────────────────────────

class TodayStatusResponse(BaseSchema):
    success: bool = True
    day_number: int
    user_completed: bool
    partner_completed: bool
    comparison_ready: bool


# ── Comparison ───────────────────────────────────────────────────────────────

class ComparisonResponse(BaseSchema):
    success: bool = True
    day_number: int
    suggestions: List[str] = []
    partner_completed: bool = False


# ── Reflection History ───────────────────────────────────────────────────────

class SessionHistoryItem(BaseSchema):
    session_id: int
    day_number: int
    is_completed: bool
    completed_at: Optional[str] = None
