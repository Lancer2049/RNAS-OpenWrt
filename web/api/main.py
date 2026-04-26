"""RNAS Management API."""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import status, config

app = FastAPI(title="RNAS API", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(status.router, prefix="/api", tags=["Status"])
app.include_router(config.router, prefix="/api", tags=["Config"])


@app.get("/api/health")
async def health():
    return {"status": "ok", "version": "2.0.0"}
