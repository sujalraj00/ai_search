import google.generativeai as genai
from config import Settings
from services.mcp_client_service import MCPServer
import json
import re
from typing import AsyncGenerator, Dict, Any, List

settings = Settings()

class EnhancedLLMService:
    def __init__(self):
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel("gemini-2.0-flash")
        self.mcp_server = MCPServer()
        self.chat_history = []

    async def initialize(self):
        """Initialize MCP server (local, no connection needed)"""
        print(f"Local MCP server initialized. Available tools: {[tool.name for tool in self.mcp_server.tools]}")

    def _is_twitter_related(self, query: str) -> bool:
        """Check if query is related to Twitter posting"""
        twitter_keywords = [
            'tweet', 'twitter', 'post on twitter', 'share on twitter',
            'twitter post', 'tweet this', 'post to twitter', 'make a post on twitter'
        ]
        query_lower = query.lower()
        return any(keyword in query_lower for keyword in twitter_keywords)

    async def generate_response_with_tools(self, query: str, search_results: List[dict] = None):
        """Generate response with tool calling capability"""
        # Check if this is a Twitter-related query
        if self._is_twitter_related(query):
            yield f"🔍 Detected Twitter posting request. Preparing to post...\n\n"
            
            # Extract content and post to Twitter
            content = self._extract_tweet_content(query)
            if content:
                # Generate a better tweet using Gemini
                full_prompt = f"""
                Create a concise, engaging tweet about: {query}
                Keep it under 280 characters and make it interesting for Twitter.
                Think and reason deeply and provide a comprehensive, detailed, well-cited accurate response using the above context.
                Return only the tweet text, nothing else.
                """
                
                try:
                    # Generate the tweet content using Gemini
                    response = self.model.generate_content(full_prompt)
                    tweet_text = response.text if response.text else content
                    
                    yield f"📝 Content to tweet: '{tweet_text}'\n\n"
                    
                    # Call the Twitter tool directly with the extracted text
                    result = await self.mcp_server.call_tool("createPost", {"status": tweet_text})
                    
                    if result.get("content"):
                        result_text = result["content"][0].get("text", "")
                        yield f"✅ {result_text}\n"
                    else:
                        yield "✅ Tweet posted successfully!\n"
                        
                except Exception as e:
                    yield f"❌ Error generating tweet content: {str(e)}\n"
                    # Fallback to original content
                    yield f"📝 Using extracted content: '{content}'\n\n"
                    
                    result = await self.mcp_server.call_tool("createPost", {"status": content})
                    if result.get("content"):
                        result_text = result["content"][0].get("text", "")
                        yield f"✅ {result_text}\n"
                    else:
                        yield "✅ Tweet posted successfully!\n"
            else:
                yield "❌ Could not extract content to tweet. Please specify what you want to post.\n"
            return

        # For other queries, use regular search response
        async for chunk in self._generate_search_response(query, search_results):
            yield chunk

    def _extract_tweet_content(self, query: str) -> str:
        """Extract content to tweet from the query"""
        # Remove common Twitter-related phrases to get the content
        patterns = [
            r"tweet\s+(?:this\s+)?[:\-]?\s*['\"]?(.*?)['\"]?$",
            r"post\s+(?:on\s+)?twitter\s*[:\-]?\s*['\"]?(.*?)['\"]?$", 
            r"share\s+(?:on\s+)?twitter\s*[:\-]?\s*['\"]?(.*?)['\"]?$",
            r"twitter\s+post\s*[:\-]?\s*['\"]?(.*?)['\"]?$",
            r"make\s+a\s+post\s+on\s+twitter\s*[:\-]?\s*['\"]?(.*?)['\"]?$",
            r"create\s+a\s+post\s+on\s+twitter\s*[:\-]?\s*['\"]?(.*?)['\"]?$"
        ]
        
        query_clean = query.strip()
        
        for pattern in patterns:
            match = re.search(pattern, query_clean, re.IGNORECASE)
            if match:
                content = match.group(1).strip()
                if content:
                    return content
        
        # If no pattern matches, try to extract quoted content
        quoted_match = re.search(r'["\']([^"\']+)["\']', query_clean)
        if quoted_match:
            return quoted_match.group(1)
        
        # As a fallback, remove common command words and return the rest
        command_words = ['tweet', 'post', 'share', 'twitter', 'on', 'this', ':', '-', 'make', 'a', 'create']
        words = query_clean.split()
        filtered_words = [word for word in words if word.lower() not in command_words]
        
        if filtered_words:
            return ' '.join(filtered_words)
        
        return ""



    async def _generate_search_response(self, query: str, search_results: List[dict]):
        """Generate regular search-based response"""
        if not search_results:
            yield "I need search results to provide a comprehensive response."
            return

        context_text = "\n\n".join([
            f"Source {i+1} ({result['url']}):\n{result['content']}"
            for i, result in enumerate(search_results)
        ])
        
        full_prompt = f"""
        Context from web search:
        {context_text}

        Query: {query}

        Please provide a comprehensive, detailed, well-cited accurate response using the above context.
        Think and reason deeply. Ensure it answers the query the user is asking. Do not use your knowledge until it is absolutely necessary. 
        """

        try:
            response = self.model.generate_content(full_prompt, stream=True)
            for chunk in response:
                if chunk.text:
                    yield chunk.text
        except Exception as e:
            yield f"Error generating response: {str(e)}"

    # Keep the original method for backward compatibility
    async def generate_response(self, query: str, search_results: list[dict]):
        """Original method - now calls the enhanced version"""
        async for chunk in self.generate_response_with_tools(query, search_results):
            yield chunk

    async def cleanup(self):
        """Cleanup resources"""
        await self.mcp_server.close()