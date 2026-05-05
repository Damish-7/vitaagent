"""
services/llm_service.py
───────────────────────
Loads the Qwen model once at startup and exposes a generate() function.
Falls back to a rule-based response if the model is not available.
"""

import os
import re
import json
from typing import Any, Dict

_model     = None
_tokenizer = None
_loaded    = False

MODEL_NAME = os.getenv("LLM_MODEL", "Qwen/Qwen2.5-0.5B-Instruct")

SYSTEM_PROMPT = (
    "You are Vijay, a health assistant. "
    "You MUST return ONLY a raw JSON object. "
    "No markdown. No explanation. "
    'For exercise queries: {"exercise_plan": {"morning": ["exercise - description"], '
    '"evening": ["exercise - description"], "tips": ["tip"]}} '
    'For diet queries: {"diet_plan": {"breakfast": ["food - portion"], '
    '"lunch": ["food - portion"], "dinner": ["food - portion"]}} '
    'For general health queries: {"advice": "detailed text here"} '
    "Include at least 4 items per section with brief descriptions. "
    "START your response with { and END with }"
)


def load_model() -> bool:
    """Load the Qwen model. Returns True on success."""
    global _model, _tokenizer, _loaded
    if _loaded:
        return True
    try:
        from transformers import AutoModelForCausalLM, AutoTokenizer
        import torch

        print(f"[LLM] Loading {MODEL_NAME} …")
        _tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
        _model     = AutoModelForCausalLM.from_pretrained(
            MODEL_NAME, device_map="auto"
        )
        _loaded = True
        print("[LLM] Model loaded ✅")
        return True
    except Exception as exc:
        print(f"[LLM] Could not load model: {exc}")
        print("[LLM] Falling back to rule-based responses.")
        return False


def _rule_based(message: str) -> Dict[str, Any]:
    """Simple keyword-based fallback when the model is unavailable."""
    msg = message.lower()
    if any(kw in msg for kw in ["exercise", "workout", "gym", "run", "fitness"]):
        return {
            "exercise_plan": {
                "morning": [
                    "Morning run - 30 min steady-paced jogging",
                    "Dynamic warm-up - 10 min stretching",
                    "Bodyweight squats - 3 sets of 15 reps",
                    "Push-ups - 3 sets of 12 reps",
                ],
                "evening": [
                    "Yoga flow - 20 min flexibility session",
                    "Resistance band exercises - 30 min upper body",
                    "Core workout - 15 min planks and crunches",
                    "Cool-down walk - 10 min easy pace",
                ],
                "tips": [
                    "Stay hydrated — drink water before, during, and after exercise",
                    "Rest at least one day per week for recovery",
                    "Increase intensity gradually to avoid injury",
                    "Track your progress weekly",
                ],
            }
        }
    elif any(kw in msg for kw in ["diet", "eat", "food", "meal", "nutrition", "calorie"]):
        return {
            "diet_plan": {
                "breakfast": [
                    "Quinoa veggie bowl - 60g quinoa + spinach + egg whites",
                    "Greek yogurt parfait - 150g yogurt + berries + granola",
                    "Oats with low-fat milk - 50g oats + almonds + honey",
                    "Whole wheat toast + peanut butter + banana",
                ],
                "lunch": [
                    "Grilled chicken Mediterranean bowl - 150g chicken + brown rice",
                    "Dal tadka + 2 multigrain roti + salad",
                    "Paneer tikka wrap + mint chutney",
                    "Lentil soup + whole grain bread",
                ],
                "dinner": [
                    "Baked salmon + stir-fried vegetables + quinoa",
                    "Moong dal soup + brown bread + salad",
                    "Tofu stir-fry + small portion brown rice",
                    "Grilled vegetables + hummus + pita",
                ],
            }
        }
    else:
        return {
            "advice": (
                "Based on your profile, I recommend: "
                "1) Drink at least 2.5L of water daily. "
                "2) Aim for 10,000 steps per day. "
                "3) Include 30 minutes of moderate exercise 5 days a week. "
                "4) Eat a balanced diet rich in protein, fiber, and healthy fats. "
                "5) Sleep 7-8 hours per night for optimal recovery. "
                "Would you like a specific diet or exercise plan?"
            )
        }


def _parse_json_from_text(text: str) -> Dict[str, Any]:
    """Extract and merge all JSON objects from the model output."""
    text = text.replace("```json", "").replace("```", "").strip()
    matches = re.findall(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', text, re.DOTALL)
    merged: Dict[str, Any] = {}
    for m in matches:
        try:
            merged.update(json.loads(m))
        except json.JSONDecodeError:
            continue
    return merged


def generate(message: str) -> Dict[str, Any]:
    """
    Generate a response for the given user message.
    Uses Qwen if available, otherwise rule-based fallback.
    """
    if not _loaded:
        return _rule_based(message)

    try:
        messages = [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user",   "content": message},
        ]
        text = _tokenizer.apply_chat_template(
            messages, tokenize=False, add_generation_prompt=True
        )
        inputs    = _tokenizer([text], return_tensors="pt").to(_model.device)
        input_len = inputs["input_ids"].shape[1]

        output = _model.generate(
            **inputs,
            max_new_tokens=400,
            do_sample=False,
            pad_token_id=_tokenizer.eos_token_id,
        )
        new_tokens = output[0][input_len:]
        result     = _tokenizer.decode(new_tokens, skip_special_tokens=True).strip()

        print(f"[LLM] Raw output: {result[:200]}…")

        parsed = _parse_json_from_text(result)
        if parsed:
            return parsed
        else:
            return {"response": result, "warning": "Model did not return valid JSON"}

    except Exception as exc:
        print(f"[LLM] Generation error: {exc}")
        return _rule_based(message)