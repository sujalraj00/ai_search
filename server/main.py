from fastapi import FastAPI
from pydantic_models.chat_body import ChatBody
from search_service.search_service import SearchService
from search_service.sort_source_service import SortSourceService

app = FastAPI()

search_service = SearchService()
sort_service = SortSourceService()

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
    return body.query

