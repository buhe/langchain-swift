![](https://p.ipic.vip/2qqnzz.png)
# 🐇 LangChain Swift
[![Swift](https://github.com/buhe/langchain-swift/actions/workflows/swift.yml/badge.svg)](https://github.com/buhe/langchain-swift/actions/workflows/swift.yml) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Swift Package Manager](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg) [![Twitter](https://img.shields.io/badge/twitter-@buhe1986-blue.svg?style=flat)](http://twitter.com/buhe1986)

🚀 LangChain for Swift. Optimized for iOS, macOS and visionOS.(beta)


## Setup
1. Create **env.txt** file in main project at root directory.
2. Set some var like OPENAI_API_KEY or OPENAI_API_BASE

Like this.

```
OPENAI_API_KEY=sk-xxx
OPENAI_API_BASE=xxx
SUPABASE_URL=xxx
SUPABASE_KEY=xxx
SERPER_API_KEY=xxx
HF_API_KEY=xxx
BAIDU_OCR_AK=xxx
BAIDU_OCR_SK=xxx
BAIDU_LLM_AK=xxx
BAIDU_LLM_SK=xxx
CHATGLM_API_KEY=xxx
OPENWEATHER_API_KEY=xxx
LLAMA2_API_KEY=xxx
GOOGLEAI_API_KEY=xxx
```

## Get stated
<details>
<summary>💬 Chatbots</summary>
    
Code

```swift
let template = """
Assistant is a large language model trained by OpenAI.

Assistant is designed to be able to assist with a wide range of tasks, from answering simple questions to providing in-depth explanations and discussions on a wide range of topics. As a language model, Assistant is able to generate human-like text based on the input it receives, allowing it to engage in natural-sounding conversations and provide responses that are coherent and relevant to the topic at hand.

Assistant is constantly learning and improving, and its capabilities are constantly evolving. It is able to process and understand large amounts of text, and can use this knowledge to provide accurate and informative responses to a wide range of questions. Additionally, Assistant is able to generate its own text based on the input it receives, allowing it to engage in discussions and provide explanations and descriptions on a wide range of topics.

Overall, Assistant is a powerful tool that can help with a wide range of tasks and provide valuable insights and information on a wide range of topics. Whether you need help with a specific question or just want to have a conversation about a particular topic, Assistant is here to assist.

{history}
Human: {human_input}
Assistant:
"""

let prompt = PromptTemplate(input_variables: ["history", "human_input"], partial_variable: [:], template: template)


let chatgpt_chain = LLMChain(
    llm: OpenAI(),
    prompt: prompt,
    memory: ConversationBufferWindowMemory()
)
Task(priority: .background)  {
    var input = "I want you to act as a Linux terminal. I will type commands and you will reply with what the terminal should show. I want you to only reply with the terminal output inside one unique code block, and nothing else. Do not write explanations. Do not type commands unless I instruct you to do so. When I need to tell you something in English I will do so by putting text inside curly brackets {like this}. My first command is pwd."
    
    var res = await chatgpt_chain.predict(args: ["human_input": input])
    print(input)
    print("🌈:" + res!)
    input = "ls ~"
    res = await chatgpt_chain.predict(args: ["human_input": input])
    print(input)
    print("🌈:" + res!)
}
```
Log
```
I want you to act as a Linux terminal. I will type commands and you will reply with what the terminal should show. I want you to only reply with the terminal output inside one unique code block, and nothing else. Do not write explanations. Do not type commands unless I instruct you to do so. When I need to tell you something in English I will do so by putting text inside curly brackets {like this}. My first command is pwd.
🌈:
/home/user

ls ~
🌈:
Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos

```
</details>
<details>
<summary>❓ QA bot</summary>
    
An [main/Sources/LangChain/vectorstores/supabase/supabase.sql](https://github.com/buhe/langchain-swift/blob/main/Sources/LangChain/vectorstores/supabase/supabase.sql) is required.

ref: https://supabase.com/docs/guides/database/extensions/pgvector

Code
```swift
Task(priority: .background)  {
    let loader = TextLoader(file_path: "state_of_the_union.txt")
    let documents = await loader.load()
    let text_splitter = CharacterTextSplitter(chunk_size: 1000, chunk_overlap: 0)

    let embeddings = OpenAIEmbeddings()
    let s = Supabase(embeddings: embeddings)
    for text in documents {
        let docs = text_splitter.split_text(text: text.page_content)
        for doc in docs {
            await s.addText(text: doc)
        }
    }
    
    let m = await s.similaritySearch(query: "What did the president say about Ketanji Brown Jackson", k: 1)
    print("Q🖥️:What did the president say about Ketanji Brown Jackson")
    print("A🚀:\(m)")
}
```
Log
```
Q🖥️:What did the president say about Ketanji Brown Jackson
A🚀:[LangChain.MatchedModel(content: Optional("In state after state, new laws have been passed, not only to suppress the vote, but to subvert entire elections. We cannot let this happen. Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence. "), similarity: 0.8024642)]
```
</details>
<details>

<summary>📄 Retriever</summary>
    
Code
```swift
Task(priority: .background)  {
    let retriever = WikipediaRetriever()
    let qa = ConversationalRetrievalChain(retriver: retriever, llm: OpenAI())
    let questions = [
        "What is Apify?",
        "When the Monument to the Martyrs of the 1830 Revolution was created?",
        "What is the Abhayagiri Vihāra?"
    ]
    var chat_history:[(String, String)] = []

    for question in questions{
        let result = await qa.predict(args: ["question": question, "chat_history": ConversationalRetrievalChain.get_chat_history(chat_history: chat_history)])
        chat_history.append((question, result!))
        print("⚠️**Question**: \(question)")
        print("✅**Answer**: \(result!)")
    }
}
```
Log
```
⚠️**Question**: What is Apify?
✅**Answer**: Apify refers to a web scraping and automation platform.
read(descriptor:pointer:size:): Connection reset by peer (errno: 54)
⚠️**Question**: When the Monument to the Martyrs of the 1830 Revolution was created?
✅**Answer**: The Monument to the Martyrs of the 1830 Revolution was created in 1906.
⚠️**Question**: What is the Abhayagiri Vihāra?
✅**Answer**: The term "Abhayagiri Vihāra" refers to a Buddhist monastery in ancient Sri Lanka.
```
</details>
<details>

<summary>🤖 Agent</summary>
    
Code
```swift
let agent = initialize_agent(llm: OpenAI(), tools: [WeatherTool()])
Task(priority: .background)  {
    let res = await agent.run(args: "Query the weather of this week")
    switch res {
    case Parsed.str(let str):
        print("🌈:" + str)
    default: break
    }
}
```
Log
```
🌈: The weather for this week is sunny.
```
</details>
<details>
    
<summary>📡 Router</summary>
    
```swift
let physics_template = """
You are a very smart physics professor. \
You are great at answering questions about physics in a concise and easy to understand manner. \
When you don't know the answer to a question you admit that you don't know.

Here is a question:
{input}
"""


let math_template = """
You are a very good mathematician. You are great at answering math questions. \
You are so good because you are able to break down hard problems into their component parts, \
answer the component parts, and then put them together to answer the broader question.

Here is a question:
{input}
"""
   
let prompt_infos = [
   [
       "name": "physics",
       "description": "Good for answering questions about physics",
       "prompt_template": physics_template,
   ],
   [
       "name": "math",
       "description": "Good for answering math questions",
       "prompt_template": math_template,
   ]
]

let llm = OpenAI()

var destination_chains: [String: DefaultChain] = [:]
for p_info in prompt_infos {
   let name = p_info["name"]!
   let prompt_template = p_info["prompt_template"]!
   let prompt = PromptTemplate(input_variables: ["input"], partial_variable: [:], template: prompt_template)
   let chain = LLMChain(llm: llm, prompt: prompt, parser: StrOutputParser())
   destination_chains[name] = chain
}
let default_prompt = PromptTemplate(input_variables: [], partial_variable: [:], template: "")
let default_chain = LLMChain(llm: llm, prompt: default_prompt, parser: StrOutputParser())

let destinations = prompt_infos.map{
   "\($0["name"]!): \($0["description"]!)"
}
let destinations_str = destinations.joined(separator: "\n")

let router_template = MultiPromptRouter.formatDestinations(destinations: destinations_str)
let router_prompt = PromptTemplate(input_variables: ["input"], partial_variable: [:], template: router_template)

let llmChain = LLMChain(llm: llm, prompt: router_prompt, parser: RouterOutputParser())

let router_chain = LLMRouterChain(llmChain: llmChain)

let chain = MultiRouteChain(router_chain: router_chain, destination_chains: destination_chains, default_chain: default_chain)
Task(priority: .background)  {
   print("💁🏻‍♂️", await chain.run(args: "What is black body radiation?"))
}
```
Log
```
router text: {
    "destination": "physics",
    "next_inputs": "What is black body radiation?"
}
💁🏻‍♂️ str("Black body radiation refers to the electromagnetic radiation emitted by an object that absorbs all incident radiation and reflects or transmits none. It is an idealized concept used in physics to understand the behavior of objects that emit and absorb radiation. \n\nAccording to Planck\'s law, the intensity and spectrum of black body radiation depend on the temperature of the object. As the temperature increases, the peak intensity of the radiation shifts to shorter wavelengths, resulting in a change in color from red to orange, yellow, white, and eventually blue.\n\nBlack body radiation is important in various fields of physics, such as astrophysics, where it helps explain the emission of radiation from stars and other celestial bodies. It also plays a crucial role in understanding the behavior of objects at high temperatures, such as in industrial processes or the study of the early universe.\n\nHowever, it\'s worth noting that while I strive to provide accurate and concise explanations, there may be more intricate details or specific mathematical formulations related to black body radiation that I haven\'t covered.")
```
</details>

### Parser

<details>
<summary>ObjectOutputParser</summary>
    
```swift
let demo = Book(title: "a", content: "b", unit: Unit(num: 1))

var parser = ObjectOutputParser(demo: demo)

let llm = OpenAI()

let t = PromptTemplate(input_variables: ["query"], partial_variable:["format_instructions": parser.get_format_instructions()], template: "Answer the user query.\n{format_instructions}\n{query}\n")

let chain = LLMChain(llm: llm, prompt: t, parser: parser, inputKey: "query")
Task(priority: .background)  {
    let pasred = await chain.run(args: "The book title is 123 , content is 456 , num of unit is 7")
    switch pasred {
    case Parsed.object(let o): print("🚗object: \(o)")
    default: break
    }
}
```
</details>

<details>
<summary>EnumOutputParser</summary>

```swift
    enum MyEnum: String, CaseIterable  {
        case value1
        case value2
        case value3
    }
    for v in MyEnum.allCases {
        print(v.rawValue)
    }
    let llm = OpenAI()
    let parser = EnumOutputParser<MyEnum>(enumType: MyEnum.self)
    let i = parser.get_format_instructions()
    print("ins: \(i)")
    let t = PromptTemplate(input_variables: ["query"], partial_variable:["format_instructions": parser.get_format_instructions()], template: "Answer the user query.\n{format_instructions}\n{query}\n")
    
    let chain = LLMChain(llm: llm, prompt: t, parser: parser, inputKey: "query")
    Task(priority: .background)  {
        let result = await chain.run(args: "Value is 'value2'")
        switch result {
           case .enumType(let e):
               print("🦙enum: \(e)")
           default:
               print("parse fail. \(result)")
           }
    }
```
</details>

### Other

<details>
<summary>Stream Chat - Must be use ChatOpenAI model </summary>

```swift
Task(priority: .background)  {
    let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    
    let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
    
    defer {
        // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
        try? httpClient.syncShutdown()
    }
    let llm = ChatOpenAI(httpClient: httpClient, temperature: 0.8)
    let answer = await llm.generate(text: "Hey")
    print("🥰")
    for try await c in answer!.getGeneration()! {
        if let message = c {
            print(message)
        }
    }
}
```
</details>

## 🌐 Trusted by
<a href="https://apps.apple.com/us/app/convict-conditioning-pro/id1661449971">
<img src="https://www.buhe.dev/_next/image?url=%2Fassets%2FCC.png&w=256&q=75" alt="Convict Conditioning" style="width:15%">
</a>
<a href="https://apps.apple.com/us/app/investment-for-long-term/id1665352936">
<img src="https://www.buhe.dev/_next/image?url=%2Fassets%2FInvestDash.png&w=256&q=75" alt="Investment For Long Term" style="width:15%">
</a>
<a href="https://apps.apple.com/us/app/ai-summarize-pro/id6450951898">
<img src="https://www.buhe.dev/_next/image?url=%2Fassets%2FAISummary.png&w=256&q=75" alt="AI Summary" style="width:15%">
</a>
<a href="https://apps.apple.com/us/app/ai-pagily/id6452588389">
<img src="https://www.buhe.dev/_next/image?url=%2Fassets%2FPagily.png&w=256&q=75" alt="AI Pagily" style="width:15%">
</a>
<a href="https://apps.apple.com/us/app/b-%E7%AB%99-ai-%E6%80%BB%E7%BB%93/id6455595076">
<img src="https://www.buhe.dev/_next/image?url=%2Fassets%2FBilibiliSummary.png&w=256&q=75" alt="B 站 AI 总结" style="width:15%">
</a>
<a href="https://apps.apple.com/us/app/%E5%B8%AE%E4%BD%A0%E5%86%99%E4%BD%9C%E6%96%87/id6458487704">
<img src="https://www.buhe.dev/_next/image?url=%2Fassets%2FWriter.png&w=256&q=75" alt="帮你写作文" style="width:15%">
</a>

[Open an issue or PR to add your app.](https://github.com/buhe/langchain-swift/issues/new)

## 🚗 Roadmap
- LLMs
    - [x] OpenAI
    - [x] Hugging Face
    - [x] Dalle
    - [x] ChatGLM
    - [x] ChatOpenAI
    - [x] Baidu
    - [x] Llama 2
    - [x] Gemini
- Vectorstore
    - [x] Supabase
    - [x] SimilaritySearchKit
- Store
    - [x] BaseStore
    - [x] InMemoryStore
    - [x] FileStore
- Embedding
    - [x] OpenAI
- Chain
    - [x] Base
    - [x] LLM
    - [x] SimpleSequentialChain
    - [x] SequentialChain
    - [x] TransformChain
    - Router
        - [x] LLMRouterChain
        - [x] MultiRouteChain
    - QA
        - [x] ConversationalRetrievalChain
- Tools
    - [x] Dummy
    - [x] InvalidTool
    - [x] Serper
    - [ ] Zapier
    - [x] JavascriptREPLTool(Via JSC)
    - [x] GetLocation(Via CoreLocation)
    - [x] Weather
    - [x] TTSTool
- Agent
    - [x] ZeroShotAgent
- Memory
    - [x] BaseMemory
    - [x] BaseChatMemory
    - [x] ConversationBufferWindowMemory
    - [x] ReadOnlySharedMemory
- Text Splitter
    - [x] CharacterTextSplitter
    - [x] RecursiveCharacterTextSplitter
- Document Loader
    - [x] TextLoader
    - [x] YoutubeLoader
    - [x] HtmlLoader
    - [x] PDFLoader
    - [x] BilibilLoader
    - [x] ImageOCRLoader
    - [x] AudioLoader
- OutputParser
    - [x] MRKLOutputParser
    - [x] ListOutputParser
    - [x] SimpleJsonOutputParser
    - [x] StrOutputParser
    - [x] RouterOutputParser
    - [x] ObjectOutputParser
    - [x] EnumOutputParser
    - [x] DateOutputParser
- Prompt
    - [x] PromptTemplate
    - [x] MultiPromptRouter
- Callback
    - [x] StdOutCallbackHandler 
- LLM Cache
    - [x] InMemery
    - [x] File
- Retriever
    - [x] WikipediaRetriever
    - [x] PubmedRetriever
    - [x] ParentDocumentRetriever
## 👍 Got Ideas?
Open an issue, and let's discuss!

Join Slack: https://join.slack.com/t/langchain-mobile/shared_invite/zt-26tzdzb2u-8RnP7hDQz~MWMg8EeIu0lQ

## 💁 Contributing
As an open-source project in a rapidly developing field, we are extremely open to contributions, whether it be in the form of a new feature, improved infrastructure, or better documentation.
