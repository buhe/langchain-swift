# 🐇 LangChain Swift
[![Swift](https://github.com/buhe/langchain-swift/actions/workflows/swift.yml/badge.svg)](https://github.com/buhe/langchain-swift/actions/workflows/swift.yml) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Swift Package Manager](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg) [![Twitter](https://img.shields.io/badge/twitter-@buhe1986-blue.svg?style=flat)](http://twitter.com/buhe1986)


A langchain copy, for ios or mac apps.


## Setup
1. Create env.txt file in main project at root directory.
2. Set some var like OPENAI_API_KEY or OPENAI_API_BASE

Like this.

```
OPENAI_API_KEY=sk-xxx
OPENAI_API_BASE=xxx
SUPABASE_URL=xxx
SUPABASE_KEY=xxx
SERPER_API_KEY=xxx
HF_API_KEY=xxx
```

### Support env var
- OPENAI_API_KEY
- OPENAI_API_BASE
- SUPABASE_URL
- SUPABASE_KEY
- SERPER_API_KEY
- HF_API_KEY

## Get stated
### 💬 Chatbots
Code
```swift
let template = """
Assistant is a large language model trained by OpenAI.

Assistant is designed to be able to assist with a wide range of tasks, from answering simple questions to providing in-depth explanations and discussions on a wide range of topics. As a language model, Assistant is able to generate human-like text based on the input it receives, allowing it to engage in natural-sounding conversations and provide responses that are coherent and relevant to the topic at hand.

Assistant is constantly learning and improving, and its capabilities are constantly evolving. It is able to process and understand large amounts of text, and can use this knowledge to provide accurate and informative responses to a wide range of questions. Additionally, Assistant is able to generate its own text based on the input it receives, allowing it to engage in discussions and provide explanations and descriptions on a wide range of topics.

Overall, Assistant is a powerful tool that can help with a wide range of tasks and provide valuable insights and information on a wide range of topics. Whether you need help with a specific question or just want to have a conversation about a particular topic, Assistant is here to assist.

%@
Human: %@
Assistant:
"""

let prompt = PromptTemplate(input_variables: ["history", "human_input"], template: template)


let chatgpt_chain = LLMChain(
    llm: OpenAI(),
    prompt: prompt,
    parser: Nothing(),
    memory: ConversationBufferWindowMemory()
)
Task {
    var input = ["human_input": "I want you to act as a Linux terminal. I will type commands and you will reply with what the terminal should show. I want you to only reply with the terminal output inside one unique code block, and nothing else. Do not write explanations. Do not type commands unless I instruct you to do so. When I need to tell you something in English I will do so by putting text inside curly brackets {like this}. My first command is pwd."
    ]
    var output = await chatgpt_chain.predict(args: input)
    print(input["human_input"]!)
    print(output["Answer"]!)
    input = ["human_input": "ls ~"]
    output = await chatgpt_chain.predict(args: input)
    print(input["human_input"]!)
    print(output["Answer"]!)
}
```
Log
```
I want you to act as a Linux terminal. I will type commands and you will reply with what the terminal should show. I want you to only reply with the terminal output inside one unique code block, and nothing else. Do not write explanations. Do not type commands unless I instruct you to do so. When I need to tell you something in English I will do so by putting text inside curly brackets {like this}. My first command is pwd.

/home/user

ls ~

Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos

```
### ❓ QA bot
Code
```swift
let loader = TextLoader(file_path: "state_of_the_union.txt")
let documents = loader.load()
let text_splitter = CharacterTextSplitter(chunk_size: 1000, chunk_overlap: 0)

let embeddings = OpenAIEmbeddings()
let s = Supabase(embeddings: embeddings)
Task {
    for text in documents {
        let docs = text_splitter.split_text(text: text.page_content)
        for doc in docs {
            await s.addText(text: doc)
        }
    }
    
    let m = await s.similaritySearch(query: "What did the president say about Ketanji Brown Jackson", k: 1)
    print("Q:What did the president say about Ketanji Brown Jackson")
    print("A:\(m)")
}
```
Log
```
Q:What did the president say about Ketanji Brown Jackson
A:[LangChain.MatchedModel(content: Optional("In state after state, new laws have been passed, not only to suppress the vote, but to subvert entire elections. We cannot let this happen. Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence. "), similarity: 0.80242604)]
```
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
## 🌐 Real world
- https://github.com/buhe/AISummary
- https://github.com/buhe/HtmlSummary

## 🚗 Roadmap
- LLMs
  - [x] OpenAI
  - [x] Hugging Face
  - [ ] ChatGLM
  - [ ] Baidu
  - [ ] Llama 2
- Vectorstore
  - [x] Supabase
- Embedding
  - [x] OpenAI
- Chain
  - [x] Base
  - [x] LLM
- Tools
  - [x] Dummy
  - [x] InvalidTool
  - [x] Serper
  - [ ] Zapier
- Agent
  - [x] ZeroShotAgent
- Memory
    - [x] BaseMemory
    - [x] BaseChatMemory
    - [x] ConversationBufferWindowMemory
    - [x] ReadOnlySharedMemory
- Text Splitter
    - [x] CharacterTextSplitter
- Document Loader
    - [x] TextLoader
    - [x] YoutubeLoader
    - [x] HtmlLoader
    - [x] PDFLoader
    - [x] BilibilLoader

## 👍 Got Ideas?
Open an issue, and let's discuss!

## 💁 Contributing
As an open-source project in a rapidly developing field, we are extremely open to contributions, whether it be in the form of a new feature, improved infrastructure, or better documentation.
