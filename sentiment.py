from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

# FinBERT 모델 로딩
tokenizer = AutoTokenizer.from_pretrained("ProsusAI/finbert")
model = AutoModelForSequenceClassification.from_pretrained("ProsusAI/finbert")

label_map = {0: "negative", 1: "neutral", 2: "positive"}

def analyze_sentiment(text: str) -> str:
    if not text or len(text.strip()) < 20:
        return "neutral"

    inputs = tokenizer(text, return_tensors="pt", truncation=True, max_length=512)
    outputs = model(**inputs)
    probs = torch.nn.functional.softmax(outputs.logits, dim=1)
    label = torch.argmax(probs).item()

    return label_map[label]
