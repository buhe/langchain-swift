# 🐇 LangChain Swift
[![Swift](https://github.com/buhe/langchain-swift/actions/workflows/swift.yml/badge.svg)](https://github.com/buhe/langchain-swift/actions/workflows/swift.yml) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A serious and mini swift langchain copy, for ios or mac apps.


## Setup
1. Create env.txt file in main project.
2. Set some var like OPENAI_API_KEY or OPENAI_API_BASE

### Support env var
- OPENAI_API_KEY
- OPENAI_API_BASE
- SUPABASE_URL
- SUPABASE_KEY

## Get stated
### 💬 Chatbots

### ❓ QA bot

### 🤖 Agent
Code
```swift
let agent = initialize_agent(llm: llm, tools: [WeatherTool()])
let answer = await agent.run(args: "Query the weather of this week")
print(answer)
```
Log
```
Answer the following questions as best you can. You have access to the following tools:

Weather:useful for When you want to know about the weather

Use the following format:

Question: the input question you must answer
Thought: you should always think about what to do
Action: the action to take, should be one of [Weather]
Action Input: the input to the action
Observation: the result of the action
... (this Thought/Action/Action Input/Observation can repeat N times)
Thought: I now know the final answer
Final Answer: the final answer to the original input question

Begin!

Question: Query the weather of this week
Thought:     This was your previous work
    but I haven't seen any of it! I only see what "
    you return as final answer):
I need to know the location for which I want to check the weather
Action: Weather
Action Input: Location
Observation: Sunny^_^
Thought: I need to know the specific days for which I want to check the weather
Action: Weather
Action Input: Days of the week
Observation: Sunny^_^
Thought: 
final answer.
 The weather for the specified location and days of the week is sunny.
```
## Roadmap
- [ ] LLMs
  - [x] OpenAI
- [ ] Vectorstore
  - [x] Supabase
- [ ] Embedding
  - [x] OpenAI
- [ ] Chain
  - [x] Base
  - [x] LLM
- [ ] Tools
  - [x] Dummy
  - [x] InvalidTool
  - [ ] Serper
  - [ ] Zapier
- [ ] Agent
  - [x] ZeroShotAgent
- [ ] Memory

## 💁 Contributing
As an open-source project in a rapidly developing field, we are extremely open to contributions, whether it be in the form of a new feature, improved infrastructure, or better documentation.
