"""
routes/chat.py
──────────────
POST /api/chat          — send message → get AI response (saved to DB)
GET  /api/chat/history  — fetch chat history for current user
DELETE /api/chat/history — clear chat history
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from database.connection import get_db
from models.orm_models import User, ChatHistory
from models.schemas import ChatRequest, ChatResponse, ChatMessageResponse
from services.auth_service import get_current_user
from services import llm_service

router = APIRouter(prefix="/api/chat", tags=["chat"])


@router.post("", response_model=ChatResponse)
def send_message(
    body:         ChatRequest,
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    # 1. Save user message
    db.add(ChatHistory(user_id=current_user.id, role="user", message=body.message))
    db.flush()

    # 2. Generate AI response
    ai_result = llm_service.generate(body.message)

    # 3. Serialise response to string for storage
    import json
    ai_text = (
        ai_result.get("advice")
        or json.dumps(ai_result)
    )
    db.add(ChatHistory(user_id=current_user.id, role="assistant", message=ai_text))
    db.commit()

    return ChatResponse(response=ai_result)


@router.get("/history", response_model=list[ChatMessageResponse])
def get_history(
    limit:        int     = 50,
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    rows = (
        db.query(ChatHistory)
        .filter(ChatHistory.user_id == current_user.id)
        .order_by(ChatHistory.created_at.desc())
        .limit(limit)
        .all()
    )
    return list(reversed(rows))


@router.delete("/history", status_code=204)
def clear_history(
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    db.query(ChatHistory).filter(ChatHistory.user_id == current_user.id).delete()
    db.commit()