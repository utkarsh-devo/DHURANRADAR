from typing import Optional
from enum import Enum
from pydantic import BaseModel, Field

class AdvisoryStatus(str, Enum):
    VERIFIED = "VERIFIED"
    NOT_FOUND = "NOT_FOUND"
    SOURCE_UNAVAILABLE = "SOURCE_UNAVAILABLE"

class AdvisoryResponse(BaseModel):
    status: AdvisoryStatus = AdvisoryStatus.VERIFIED
    title: str = "Official Health Advisory on Air Pollution"
    summary: str = "MoHFW/NCDC guidelines advise vulnerable groups (children, elderly, respiratory patients) to minimize outdoor evening exposure during elevated smoke/air pollution periods."
    summary_hi: Optional[str] = "स्वास्थ्य मंत्रालय / एनसीडीसी सलाह: उच्च धुएं/प्रदूषण के समय कमजोर समूह (बच्चे, बुजुर्ग, सांस के मरीज) शाम को बाहर निकलने से बचें।"
    issued_date: Optional[str] = "1 Nov 2025"
    source_name: str = "MoHFW/NCDC (NPCCHH)"
    source_url: Optional[str] = "https://ncdc.mohfw.gov.in/air-pollution-advisory"
    is_verified: bool = True
    retrieved_via: str = "TinyFish Search & Fetch"
    notice: str = Field(
        "Official source and dated",
        description="'Official source and dated' or 'No current verified advisory retrieved.'"
    )
    disclaimer: str = "Health guidance comes only from official advisories. DhuanRadar does not give medical advice."
