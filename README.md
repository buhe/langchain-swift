# 🐇 LangChain Swift
[![Swift](https://github.com/buhe/langchain-swift/actions/workflows/swift.yml/badge.svg)](https://github.com/buhe/langchain-swift/actions/workflows/swift.yml) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Swift Package Manager](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg) [![Twitter](https://img.shields.io/badge/twitter-@buhe1986-blue.svg?style=flat)](http://twitter.com/buhe1986)


A langchain copy, for ios or mac apps.


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

%@
Human: %@
Assistant:
"""

let prompt = PromptTemplate(input_variables: ["history", "human_input"], template: template)


let chatgpt_chain = LLMChain(
    llm: OpenAI(),
    prompt: prompt,
    parser: StrOutputParser(),
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
</details>
<details>
<summary>❓ QA bot</summary>
    
An [main/Sources/LangChain/vectorstores/supabase/supabase.sql](https://github.com/buhe/langchain-swift/blob/main/Sources/LangChain/vectorstores/supabase/supabase.sql) is required.

ref: https://supabase.com/docs/guides/database/extensions/pgvector

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
</details>
<details>
<summary>🤖 Agent</summary>
    
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
            let prompt = PromptTemplate(input_variables: [], template: prompt_template)
            let chain = LLMChain(llm: llm, prompt: prompt, parser: StrOutputParser())
            destination_chains[name] = chain
        }
        let default_prompt = PromptTemplate(input_variables: [], template: "")
        let default_chain = LLMChain(llm: llm, prompt: default_prompt, parser: StrOutputParser())
        
        let destinations = prompt_infos.map{
            "\($0["name"]!): \($0["description"]!)"
        }
        let destinations_str = destinations.joined(separator: "\n")
        
        let router_template = MultiPromptRouter.formatDestinations(destinations: destinations_str)
        let router_prompt = PromptTemplate(input_variables: [], template: router_template, output_parser: RouterOutputParser())
        
        let llmChain = LLMChain(llm: llm, prompt: router_prompt, parser: RouterOutputParser())
        
        let router_chain = LLMRouterChain(llmChain: llmChain)
        
        let chain = MultiRouteChain(router_chain: router_chain, destination_chains: destination_chains, default_chain: default_chain)
        Task {
            print(await chain.run(args: "What is black body radiation?"))
        }
```
Log
```
Black body radiation refers to the electromagnetic radiation emitted by an idealized object known as a black body. A black body is an object that absorbs all incident radiation and reflects or transmits none of it. It is also a perfect emitter, meaning it emits radiation at all wavelengths and intensities.

Black body radiation is characterized by its spectral distribution, which follows a specific pattern known as Planck's law. According to this law, the intensity of radiation emitted by a black body is a function of its temperature and wavelength. At higher temperatures, the peak intensity of radiation shifts towards shorter wavelengths, resulting in a bluer color. At lower temperatures, the peak intensity shifts towards longer wavelengths, resulting in a redder color.

Black body radiation has been crucial in understanding various phenomena in physics, such as the ultraviolet catastrophe and the development of quantum mechanics. It also has practical applications in fields like astrophysics, where it helps determine the temperature and composition of celestial objects based on their emitted radiation.
```
</details>

### Parser

<details>
<summary>ObjectOutputParser</summary>
    
```swift
    struct Unit: Codable {
        let num: Int
    }
    struct Book: Codable {
        let title: String
        let content: String
        let unit: Unit
    }

    let demo = Book(title: "a", content: "b", unit: Unit(num: 1))
        
        var p = ObjectOutputParser(demo: demo)
        
        let llm = OpenAI()
        
        let t = PromptTemplate(input_variables: [], template: "Answer the user query.\n" + p.get_format_instructions() + "\n%@")
        
        let chain = LLMChain(llm: llm, prompt: t, parser: p)
        Task {
            let pasred = await chain.predict_and_parse(args: ["text": "The book title is 123 , content is 456 , num of unit is 7"])
            switch pasred {
            case Parsed.object(let o): print("object: \(o)")
            default: break
            }
        }
```
</details>

<details>
<summary>EnumOutputParser</summary>

```swift
    enum MyEnum: String {
        case value1
        case value2
        case value3
    }
    let llm = OpenAI()
    let parser = EnumOutputParser<MyEnum>(enumType: MyEnum.self)
    let t = PromptTemplate(input_variables: [], template: "Answer the user query.\n" + parser.get_format_instructions() + "\n%@")
        
    let chain = LLMChain(llm: llm, prompt: t, parser: parser)
    Task {
        let result = await chain.predict_and_parse(args: ["text": "Value is 'value2"])
        switch result {
            case .enumType(let e):
                print("enum: \(e)")
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
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
		let llm = ChatOpenAI(httpClient: httpClient, temperature: 0.8)
		let answer = await llm.send(text: "Hey")
		let writerText = ""
            for try await c in answer.generation! {
                if let message = c.choices.first?.delta.content {
                    writerText += message
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
    - [ ] Llama 2
- Vectorstore
    - [x] Supabase
    - [x] Supabase by user
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
- Tools
    - [x] Dummy
    - [x] InvalidTool
    - [x] Serper
    - [ ] Zapier
    - [x] JavascriptREPLTool
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
- Prompt
    - [x] PromptTemplate
    - [x] MultiPromptRouter
- Callback
    - [x] StdOutCallbackHandler 

## 👍 Got Ideas?
Open an issue, and let's discuss!

## 💁 Contributing
As an open-source project in a rapidly developing field, we are extremely open to contributions, whether it be in the form of a new feature, improved infrastructure, or better documentation.
