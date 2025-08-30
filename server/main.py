# import asyncio
# from fastapi import FastAPI , WebSocket
# from pydantic_models.chat_body import ChatBody
# from services.search_service import SearchService
# from services.sort_source_service import SortSourceService
# from services.llm_service import LLMService

# app = FastAPI()

# search_service = SearchService()
# sort_service = SortSourceService()
# llm_service = LLMService()

# #chat websocket
# @app.websocket("/ws/chat")
# async def websocket_chat_endpoint(websocket: WebSocket):
#     await websocket.accept()

#     try:
#         await asyncio.sleep(0.1)
#         data = await websocket.receive_json()
#         print(data)
#         query = data.get("query")
#         print(query)
#         search_results = search_service.web_search(query)
#         print(search_results)
#         # sort the response
#         sorted_results = sort_service.sort_sources(query, search_results)
       
#         print("hi ", sorted_results, " ijh")
#         await asyncio.sleep(0.1)
#         await websocket.send_json({"type": 'search_result', "data": sorted_results })

#         print("hi")
#         # generate the llm resposnse
#         for chunk in llm_service.generate_response(query, sorted_results):
#             await asyncio.sleep(0.1)
#             await websocket.send_json({"type": "content", "data": chunk })
        
#     except Exception as e:
#         print(e)
#         print("Unexpected error occured")
#     finally: 
#         await websocket.close()    


# #chat
# @app.post("/chat")
# def chat_endpoint(body : ChatBody):
#     #search the web and return appropriate response
#     search_results = search_service.web_search(body.query)
#    # print(search_results)
#     # sort the response
#     sorted_results = sort_service.sort_sources(body.query, search_results)
#     print(sorted_results)
#     # generate the llm resposnse
#     response = llm_service.generate_response(body.query, sorted_results)
#     return response



import asyncio
from fastapi import FastAPI, WebSocket
from contextlib import asynccontextmanager
from pydantic_models.chat_body import ChatBody
from services.search_service import SearchService
from services.sort_source_service import SortSourceService
from services.enhanced_llm_service import EnhancedLLMService

# Global services
search_service = SearchService()
sort_service = SortSourceService()
llm_service = EnhancedLLMService()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Initialize MCP connection
    print("Initializing MCP connection...")
    await llm_service.initialize()
    print("MCP connection initialized!")
    
    yield
    
    # Shutdown: Cleanup
    print("Cleaning up resources...")
    await llm_service.cleanup()

app = FastAPI(lifespan=lifespan)

def is_twitter_related(query: str) -> bool:
    """Check if query is related to Twitter posting"""
    twitter_keywords = [
        'tweet', 'twitter', 'post on twitter', 'share on twitter',
        'twitter post', 'tweet this', 'post to twitter'
    ]
    query_lower = query.lower()
    return any(keyword in query_lower for keyword in twitter_keywords)

#chat websocket
@app.websocket("/ws/chat")
async def websocket_chat_endpoint(websocket: WebSocket):
    await websocket.accept()

    try:
        await asyncio.sleep(0.1)
        data = await websocket.receive_json()
        print(data)
        query = data.get("query")
        print(f"Received query: {query}")
        
        # Check if it's a Twitter-related query
        if is_twitter_related(query):
            print("Twitter-related query detected, skipping search...")
            await websocket.send_json({
                "type": "info", 
                "data": "Twitter posting detected. Processing..."
            })
            
            # Generate response with tool calling
            async for chunk in llm_service.generate_response_with_tools(query, []):
                await asyncio.sleep(0.1)
                await websocket.send_json({"type": "content", "data": chunk})
        else:
            # Regular search flow
            search_results = search_service.web_search(query)
            print(f"Found {len(search_results)} search results")
            
            # Sort the response
            sorted_results = sort_service.sort_sources(query, search_results)
            print(f"Sorted to {len(sorted_results)} relevant results")
            
            await asyncio.sleep(0.1)
            await websocket.send_json({
                "type": 'search_result', 
                "data": sorted_results
            })

            # Generate the LLM response
            async for chunk in llm_service.generate_response_with_tools(query, sorted_results):
                await asyncio.sleep(0.1)
                await websocket.send_json({"type": "content", "data": chunk})
        
    except Exception as e:
        print(f"Error in websocket: {e}")
        await websocket.send_json({
            "type": "error", 
            "data": f"An error occurred: {str(e)}"
        })
    finally: 
        await websocket.close()    

#chat
@app.post("/chat")
async def chat_endpoint(body: ChatBody):
    try:
        query = body.query
        
        # Check if it's a Twitter-related query
        if is_twitter_related(query):
            response_chunks = []
            async for chunk in llm_service.generate_response_with_tools(query, []):
                response_chunks.append(chunk)
            return {"response": "".join(response_chunks)}
        else:
            # Regular search flow
            search_results = search_service.web_search(query)
            sorted_results = sort_service.sort_sources(query, search_results)
            
            response_chunks = []
            async for chunk in llm_service.generate_response_with_tools(query, sorted_results):
                response_chunks.append(chunk)
            
            return {"response": "".join(response_chunks)}
            
    except Exception as e:
        print(f"Error in chat endpoint: {e}")
        return {"error": f"An error occurred: {str(e)}"}

# Health check endpoint
@app.get("/health")
async def health_check():
    mcp_status = "connected" if llm_service.mcp_server.connected else "disconnected"
    return {
        "status": "healthy",
        "mcp_status": mcp_status,
        "available_tools": [tool.name for tool in llm_service.mcp_server.tools]
    }