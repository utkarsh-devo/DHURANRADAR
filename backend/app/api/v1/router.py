from fastapi import APIRouter
from app.api.v1.endpoints import briefing, reports, relay, advisory, health

api_router = APIRouter()

api_router.include_router(briefing.router, tags=["Briefing"])
api_router.include_router(reports.router, tags=["Field Reports"])
api_router.include_router(relay.router, tags=["Downwind Relay"])
api_router.include_router(advisory.router, tags=["TinyFish Advisory"])
api_router.include_router(health.router, tags=["Health & Status"])
