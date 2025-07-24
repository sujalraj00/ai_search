from fastapi import FastAPI
from pydantic_models.chat_body import ChatBody

app = FastAPI()

#chat
@app.post("/chat")
def chat_endpoint(body : ChatBody):
    #search the web and return appropriate response
    # sort the response
    # generate the llm resposnse
    return body.query

