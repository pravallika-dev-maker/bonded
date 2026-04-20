from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def home():
    return {"message": "Backend running 🚀"}

@app.get("/hello")
def hello():
    return {"msg": "Hello from backend"}