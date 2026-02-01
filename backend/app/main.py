from fastapi import FastAPI
from app.database import engine, Base

# from app.database import engine, Base


from app.routes import rides

app = FastAPI(title="CoRider Backend")
app.include_router(rides.router)

Base.metadata.create_all(bind=engine)

@app.get("/health")
def health_check():
    return {"status": "ok"}
