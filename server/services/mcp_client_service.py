import asyncio
import json
import os
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
import tweepy
from dotenv import load_dotenv

load_dotenv()

@dataclass
class Tool:
    name: str
    description: str
    parameters: Dict[str, Any]

class MCPTool:
    def __init__(self, name: str, description: str, parameters: Dict[str, Any], handler):
        self.name = name
        self.description = description
        self.parameters = parameters
        self.handler = handler

class MCPServer:
    def __init__(self):
        self.tools: List[MCPTool] = []
        self.connected = True  # Local server is always connected
        
        # Initialize Twitter client
        self.twitter_client = self._init_twitter_client()
        
        # Register tools
        self._register_tools()
    
    def _init_twitter_client(self):
        """Initialize Twitter API client using v2 endpoint"""
        try:
            # Get Twitter credentials from environment
            api_key = os.getenv('TWITTER_API_KEY')
            api_secret = os.getenv('TWITTER_API_SECRET')
            access_token = os.getenv('TWITTER_ACCESS_TOKEN')
            access_secret = os.getenv('TWITTER_ACCESS_SECRET')
            
            if not all([api_key, api_secret, access_token, access_secret]):
                print("Warning: Twitter credentials not found in environment variables")
                return None
            
            # Initialize Twitter client with v2 support
            auth = tweepy.OAuthHandler(api_key, api_secret)
            auth.set_access_token(access_token, access_secret)
            api = tweepy.API(auth)
            
            # Create v2 client
            client = tweepy.Client(
                consumer_key=api_key,
                consumer_secret=api_secret,
                access_token=access_token,
                access_token_secret=access_secret
            )
            
            print("Twitter API v2 client initialized successfully")
            return client
                
        except Exception as e:
            print(f"Failed to initialize Twitter client: {e}")
            return None
    
    def _register_tools(self):
        """Register available tools"""
        # Twitter posting tool
        self.tools.append(MCPTool(
            name="createPost",
            description="Create a post on X formally known as Twitter",
            parameters={
                "type": "object",
                "properties": {
                    "status": {"type": "string", "description": "The content to post on Twitter"}
                },
                "required": ["status"]
            },
            handler=self._handle_twitter_post
        ))
        
        print(f"Registered {len(self.tools)} tools: {[tool.name for tool in self.tools]}")
    
    async def _handle_twitter_post(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """Handle Twitter posting using v2 API"""
        try:
            status = arguments.get("status")
            if not status:
                return {
                    "content": [
                        {
                            "type": "text",
                            "text": "Error: No status content provided"
                        }
                    ]
                }
            
            if self.twitter_client:
                # Post to Twitter using v2 API (like Node.js version)
                tweet = self.twitter_client.create_tweet(text=status)
                return {
                    "content": [
                        {
                            "type": "text",
                            "text": f"Successfully tweeted: {status}"
                        }
                    ]
                }
            else:
                # Mock response when Twitter client is not available
                return {
                    "content": [
                        {
                            "type": "text",
                            "text": f"Tweeted (simulated): {status}"
                        }
                    ]
                }
                
        except Exception as e:
            print(f"Twitter posting error: {e}")
            return {
                "content": [
                    {
                        "type": "text",
                        "text": f"Error posting tweet: {str(e)}"
                    }
                ]
            }
    
    async def call_tool(self, name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """Call a specific tool with given arguments"""
        try:
            # Find the tool
            tool = next((t for t in self.tools if t.name == name), None)
            if not tool:
                return {
                    "content": [
                        {
                            "type": "text",
                            "text": f"Tool '{name}' not found"
                        }
                    ]
                }
            
            # Call the tool handler
            result = await tool.handler(arguments)
            return result
            
        except Exception as e:
            return {
                "content": [
                    {
                        "type": "text",
                        "text": f"Error calling tool '{name}': {str(e)}"
                    }
                ]
            }
    
    def get_tools_for_gemini(self) -> List[Dict[str, Any]]:
        """Convert tools to Gemini function declaration format"""
        return [
            {
                "name": tool.name,
                "description": tool.description,
                "parameters": tool.parameters
            }
            for tool in self.tools
        ]
    
    async def close(self):
        """Cleanup resources"""
        # Nothing to close for local server
        pass

# For backward compatibility, create an alias
MCPClient = MCPServer