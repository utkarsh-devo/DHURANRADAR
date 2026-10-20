import pytest
from app.services.tinyfish_service import tinyfish_service
from app.schemas.advisory import AdvisoryStatus

@pytest.mark.asyncio
async def test_tinyfish_default_verified_advisory():
    """Verify default official MoHFW/NCDC advisory retrieval."""
    advisory = await tinyfish_service.get_verified_advisory()
    assert advisory.status == AdvisoryStatus.VERIFIED
    assert advisory.is_verified is True
    assert "MoHFW/NCDC" in advisory.title or "MoHFW/NCDC" in advisory.source_name
    assert advisory.issued_date is not None
    assert hasattr(advisory, "notice")
    assert advisory.notice == "Official source and dated"

def test_tinyfish_unretrieved_advisory_format():
    """Verify format when no verified advisory is retrieved (Slide 6)."""
    advisory = tinyfish_service.get_unretrieved_advisory()
    assert advisory.status == AdvisoryStatus.SOURCE_UNAVAILABLE
    assert advisory.is_verified is False
    assert advisory.notice == "No current verified advisory retrieved."
