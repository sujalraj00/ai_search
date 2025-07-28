import asyncio
from fastapi import FastAPI , WebSocket
from pydantic_models.chat_body import ChatBody
from services.search_service import SearchService
from services.sort_source_service import SortSourceService
from services.llm_service import LLMService

app = FastAPI()

search_service = SearchService()
sort_service = SortSourceService()
llm_service = LLMService()

#chat websocket
@app.websocket("/ws/chat")
async def websocket_chat_endpoint(websocket: WebSocket):
    await websocket.accept()

    try:
        await asyncio.sleep(0.1)
        data = await websocket.receive_json()
        print(data)
        query = data.get("query")
        print(query)
        search_results = search_service.web_search(query)
        print(search_results)
        # sort the response
        sorted_results = sort_service.sort_sources(query, search_results)
       
        print("hi ", sorted_results, " ijh")
        await asyncio.sleep(0.1)
        await websocket.send_json({"type": 'search_result', "data": sorted_results })

        print("hi")
        # generate the llm resposnse
        for chunk in llm_service.generate_response(query, sorted_results):
            await asyncio.sleep(0.1)
            await websocket.send_json({"type": "content", "data": chunk })
        
    except Exception as e:
        print(e)
        print("Unexpected error occured")
    finally: 
        await websocket.close()    


#chat
@app.post("/chat")
def chat_endpoint(body : ChatBody):
    #search the web and return appropriate response
    search_results = search_service.web_search(body.query)
   # print(search_results)
    # sort the response
    sorted_results = sort_service.sort_sources(body.query, search_results)
    print(sorted_results)
    # generate the llm resposnse
    response = llm_service.generate_response(body.query, sorted_results)
    return response

