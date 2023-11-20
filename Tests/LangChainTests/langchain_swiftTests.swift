import XCTest
@testable import LangChain
import AsyncHTTPClient
import Foundation
import NIOPosix


final class langchain_swiftTests: XCTestCase {
    func testFormat() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        let s1 = PromptTemplate(input_variables: ["1", "2"], partial_variable: [:], template: "{1} | {2}").format(args: [ "1":"dog" ,"2": "cat"] )
//        print(s1)
        XCTAssertNotNil(s1)
        XCTAssertEqual(s1, "dog | cat")
    }
    
    func testZeroShotAgent() throws {
      
        let tools: [BaseTool] = [Dummy()]
        let p = ZeroShotAgent.create_prompt(tools: tools)
       
//        print(p.format(args: ["cat", "dog"]))
        let c = """
Answer the following questions as best you can. You have access to the following tools:

dummy:Useful for test.

Use the following format:

Question: the input question you must answer
Thought: you should always think about what to do
Action: the action to take, should be one of [dummy]
Action Input: the input to the action
Observation: the result of the action
... (this Thought/Action/Action Input/Observation can repeat N times)
Thought: I now know the final answer
Final Answer: the final answer to the original input question

Begin!

Question: cat
Thought: dog
"""
        XCTAssertEqual(c, p.format(args: ["question": "cat","thought": "dog"]))
    }
    
    func testCharacterTextSplitter() throws {
        let split = CharacterTextSplitter(chunk_size: 2000, chunk_overlap: 200)
       
        
        let docs = split.split_text(text: bySplit)
        print(bySplit.count)
        XCTAssertEqual(docs.count, 21)
        XCTAssertEqual(docs.first!.count, 1983)
        for doc in docs {
            XCTAssertTrue(doc.count < 2000)
        }
//        print(docs.first!.count)
    }
    
    func testConversationBufferWindowMemory() throws {
        let memory = ConversationBufferWindowMemory(k: 4)
        memory.save_context(inputs: ["Q:": "1"], outputs: ["A:": "2"])
        memory.save_context(inputs: ["Q:": "3"], outputs: ["A:": "4"])
        let ctx = memory.load_memory_variables(inputs: [:])
        
//        print(ctx)
        
        XCTAssertEqual(4, ctx["history"]!.count)
    }
    
    func testBilibilClient() async throws {
        let client = BilibiliClient(credential: BilibiliCredential(sessin: "6376fa3e%2C1705926902%2C0b561%2A71gvy_TPyZMWhUweKjYGT502_5FVZdcv8bfjvwtqdlqm8UjyEiUrkPq1AodolcSjIgBXatNwAAEgA", jct: "330aaac577464e453ea1b070fd1281ea"))
        let info = await client.fetchVideoInfo(bvid: "BV1iP411y7Vs")
        XCTAssertNotNil(info)
        XCTAssertNotEqual(info?.subtitle, "")
        
//        print(info!.subtitle)
    }
    
    func testBilibiliLoader() async throws {
        let loader = BilibiliLoader(videoId: "BV1iP411y7Vs")
        let doc = await loader.load()
//        print(doc.first!.metadata["thumbnail"]!)
        XCTAssertFalse(doc.isEmpty)
        XCTAssertNotEqual("", doc.first!.page_content)
    }
    
    func testBilibiliShort() async throws {
//        let client = BilibiliClient(credential: BilibiliCredential(sessin: "6376fa3e%2C1705926902%2C0b561%2A71gvy_TPyZMWhUweKjYGT502_5FVZdcv8bfjvwtqdlqm8UjyEiUrkPq1AodolcSjIgBXatNwAAEgA", jct: "330aaac577464e453ea1b070fd1281ea"))
        let long = await BilibiliClient.getLongUrl(short: "https://b23.tv/zxgbvRd")!
        if let _ = URL(string: "https://path?bbb=xxx") {
            let components = URLComponents(url: URL(string: long)!, resolvingAgainstBaseURL: false)
            
//            if let queryItems = components?.queryItems {
//                for item in queryItems {
//                    print(item.name) // 输出参数名
//                    print(item.value) // 输出参数值
//                }
//            }
            
            let newURL = String(format: "%@://%@%@", (components?.scheme)!, (components?.host)!, components!.path)
            XCTAssertEqual("https://www.bilibili.com/video/BV1Ch4y1Z7K6", newURL)
        } else {
            XCTAssertTrue(false)
            // else branch must fail
        }
    }
    
    func testHtmlLoader() async throws {
        let url = "https://medium.com/@michaellong/swiftui-ready-for-prime-time-53d3b96dfff0"
        let eventLoopGroup = ThreadManager.thread
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        do {
            var request = HTTPClientRequest(url: url)
            request.headers.add(name: "User-Agent", value: "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/115.0.5790.130 Mobile/15E148 Safari/604.1")
            request.method = .GET
            
            let response = try await httpClient.execute(request, timeout: .seconds(120))
            print(response.headers)
            if response.status == .ok {
                let plain = String(buffer: try await response.body.collect(upTo: 10240 * 1024))
                let loader = HtmlLoader(html: plain, url: url)
                let doc = await loader.load()
//                print("thumbnail: \(doc.first!.metadata["thumbnail"]!)")
//                print("title: \(doc.first!.metadata["title"]!)")
                
                XCTAssertFalse(doc.isEmpty)
                XCTAssertNotEqual("", doc.first!.page_content)
                XCTAssertNotEqual("", doc.first!.metadata["thumbnail"]!)
                XCTAssertNotEqual("", doc.first!.metadata["title"]!)
            }
        } catch {
            // handle error
            print(error)
        }
    }
    
    func testListOutputParser() throws {
        let parser = ListOutputParser()
        let parsed = parser.parse(text: "a,b,c,d")
        switch parsed {
        case .list(let list):
            XCTAssertEqual(4, list.count)
            XCTAssertEqual("a", list.first!)
        default: XCTAssertTrue(false)
        }
        
    }
    
    func testSimpleJsonOutputParser() throws {
        let parser = SimpleJsonOutputParser()
        let parsed = parser.parse(text: """
{"a": {
        "b": 5
}}
""")
        switch parsed {
        case .json(let json):
            XCTAssertEqual(1, json.count)
            XCTAssertEqual(5, json["a"]["b"].intValue)
        default: XCTAssertTrue(false)
        }
        
    }
    
    func testBaiduAccessToken() async throws {
        
        let eventLoopGroup = ThreadManager.thread
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        let accessToken = await BaiduClient.getAccessToken(ak: "vjLPbepeMfSIjZyzpuMCufhv", sk: "WAANBg7crEIlozpwPfplPagNzspx49Gy", httpClient: httpClient)
//        print("accessToken: \(accessToken!)")
        XCTAssertNotNil(accessToken)
    }
    
    func testOCR() async throws {
        
        let eventLoopGroup = ThreadManager.thread
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        let result = await BaiduClient.ocrImage(ak: "vjLPbepeMfSIjZyzpuMCufhv", sk: "WAANBg7crEIlozpwPfplPagNzspx49Gy", httpClient: httpClient, image: imageData)
//        print("ocr: \(result!)")
        XCTAssertNotNil(result)
        XCTAssertNotNil(result!["words_result"])
    }
    
    func testMultiPromptRouter() async throws {
        let raw = MultiPromptRouter.formatDestinations(destinations: "abc")
//        print(raw)
//        let i = MultiPromptRouter.formatInput(rawString: raw, input: "123")
//        print(i)
        let input = PromptTemplate(input_variables: ["input"], partial_variable: [:], template: raw).format(args: ["input": "123"])
//        print(input)
        XCTAssertNotNil(raw)
        XCTAssertNotNil(input)
        let c = """
        Given a raw text input to a language model select the model prompt best suited for
        the input. You will be given the names of the available prompts and a description of
        what the prompt is best suited for. You may also revise the original input if you
        think that revising it will ultimately lead to a better response from the language
        model.

        << FORMATTING >>
        Return a JSON object formatted to look like:
        {
            "destination": string \\ name of the prompt to use or "DEFAULT"
            "next_inputs": string \\ a potentially modified version of the original input
        }

        REMEMBER: "destination" MUST be one of the candidate prompt names specified below OR \
        it can be "DEFAULT" if the input is not well suited for any of the candidate prompts.
        REMEMBER: "next_inputs" can just be the original input if you don't think any \
        modifications are needed.

        << CANDIDATE PROMPTS >>
        abc

        << INPUT >>
        123

        << OUTPUT >>
        """
        XCTAssertEqual(c, input)
    }
    
    func testObjectOutputParser() async throws {
        struct Unit: Codable {
            let num: Int
        }
        struct Book: Codable {
            let title: Double
            let content: Float
            let isBuy: Bool
            let unit: [Unit]
        }
        let demo = Book(title: 1.1, content: 2.2, isBuy: true,unit: [Unit(num: 1)])
        let s = String(data: try! JSONEncoder().encode(demo), encoding: .utf8)!
//        print("json: \(s)")
//        let book = Book(title: "a", content: "b")
//        let mirror = Mirror(reflecting: book)
//        guard let types = getTypesOfProperties(inClass: Book.self) else { return }
        var parser = ObjectOutputParser<Book>(demo: demo)
        let i = parser.get_format_instructions()
        let b = parser.parse(text: s)
//        print("\(b)")
        print("i: \(i)")
        switch b {
        case Parsed.object(let o):
            XCTAssertNotNil(o)
        default:
            XCTFail()
        }
    }
   
    func testObjectOutputParser2() async throws {
        struct Unit: Codable {
            let num: Int
        }
        struct Book: Codable {
            let title: String
            let content: String
            let unit: Unit
        }
        let demo = Book(title: "a", content: "b", unit: Unit(num: 1))
        let s = String(data: try! JSONEncoder().encode(demo), encoding: .utf8)!
//        print("json: \(s)")
//        let book = Book(title: "a", content: "b")
//        let mirror = Mirror(reflecting: book)
//        guard let types = getTypesOfProperties(inClass: Book.self) else { return }
        var parser = ObjectOutputParser<Book>(demo: demo)
        let i = parser.get_format_instructions()
        let b = parser.parse(text: s)
//        print("\(b)")
        print("i: \(i)")
        switch b {
        case Parsed.object(let o):
            XCTAssertNotNil(o)
        default:
            XCTFail()
        }
    }
    
    func testHtmlLoaderForWX() async throws {
        let url = "https://mp.weixin.qq.com/s/WPyNxKlaBuzFlJyYb2-Lpw"
        let eventLoopGroup = ThreadManager.thread
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        do {
            var request = HTTPClientRequest(url: url)
            request.headers.add(name: "User-Agent", value: "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/115.0.5790.130 Mobile/15E148 Safari/604.1")
            request.method = .GET
            
            let response = try await httpClient.execute(request, timeout: .seconds(120))
            print(response.headers)
            if response.status == .ok {
                let plain = String(buffer: try await response.body.collect(upTo: 10240 * 1024))
                let loader = HtmlLoader(html: plain, url: url)
                let doc = await loader.load()
//                print("thumbnail: \(doc.first!.metadata["thumbnail"]!)")
//                print("title: \(doc.first!.metadata["title"]!)")
                
                XCTAssertFalse(doc.isEmpty)
                XCTAssertNotEqual("", doc.first!.page_content)
                XCTAssertNotEqual("", doc.first!.metadata["thumbnail"]!)
                XCTAssertNotEqual("", doc.first!.metadata["title"]!)
            }
        } catch {
            // handle error
            print(error)
        }
    }
    
    func testSimpleSequentialChain() async throws {
        class A: DefaultChain {
            init() {
                super.init(outputKey: "output", inputKey: "input")
            }
            public override func _call(args: String) async -> (LLMResult?, Parsed) {
                return (LLMResult(llm_output: args + "_A"), Parsed.nothing)
            }
        }
        class B: DefaultChain {
            init() {
                super.init(outputKey: "output", inputKey: "input")
            }
            public override func _call(args: String) async -> (LLMResult?, Parsed) {
                return (LLMResult(llm_output: args + "_B"), Parsed.nothing)
            }
        }
        let simpleSequentialChain = SimpleSequentialChain(chains: [A(), B()])
        
        let llmResult = await simpleSequentialChain._call(args: "0")
        
//        print("llm: \(llmResult.0!.llm_output!)")
        
        XCTAssertEqual("0_A_B", llmResult.0!.llm_output!)
    }
    
    func testSequentialChain() async throws {
        class A: DefaultChain {
            init(outputKey: String) {
                super.init(outputKey: outputKey, inputKey: "input")
            }
            public override func _call(args: String) async -> (LLMResult?, Parsed) {
                return (LLMResult(llm_output: args + "_A"), Parsed.nothing)
            }
        }
        class B: DefaultChain {
            init(outputKey: String) {
                super.init(outputKey: outputKey, inputKey: "input")
            }
            public override func _call(args: String) async -> (LLMResult?, Parsed) {
                return (LLMResult(llm_output: args + "_B"), Parsed.nothing)
            }
        }
        let sequentialChain = SequentialChain(chains: [A(outputKey: "_A_"), B(outputKey: "_B_")])
        
        let result = try await sequentialChain.predict(args: "0")
        
//        print("llm: \(result)")
        XCTAssertEqual("0_A", result["_A_"]!)
        XCTAssertEqual("0_A_B", result["_B_"]!)
    }
    
    func testTransformChain() async throws {
        let tc = TransformChain{
            args in
            return LLMResult(llm_output: args + "_T")
        }
        
        let result = await tc._call(args: "HO")
//        print("llm: \(result.0!.llm_output!)")
        XCTAssertEqual("HO_T", result.0!.llm_output!)
    }
    
    func testDatetimePrompt() async throws {
        let datetimeParse = DateOutputParser()
        let prompt = datetimeParse.get_format_instructions()
        print(prompt)
    }
    
    func testDatetimeParse() async throws {
        let datetimeParse = DateOutputParser()
        let res = datetimeParse.parse(text: "2001 10 13")
        switch res {
        case .date(_): XCTAssertTrue(true)
        default:XCTAssertTrue(false)
        }
//        print(res)
    }
    
    func testLoaderThrow() async throws {
        let textLoader = TextLoader(file_path: "abc.txt", callbacks:[StdOutCallbackHandler()])
        let docs = await textLoader.load()
        XCTAssertTrue(docs.isEmpty)
    }
    
    func testMRKLOutputParser() async throws {
        let p = MRKLOutputParser()
        let inputString = """
Action: the action to take, should be one of [%@]
Action Input: the input to the action
"""
        let a = p.parse(text: inputString)
        switch a {
        case .action(_): XCTAssertTrue(true)
        default: XCTAssertTrue(false)
        }
//        print(a)
        
    }
    func testWikipediaSearchAPI() async throws {
        let client = WikipediaAPIWrapper()
        let wikis = try await client.search(query: "abc")
//        print(wikis)
        XCTAssertEqual(wikis.count, 3)
    }
    
    func testWikipediaFetchPageContentAPI() async throws {
        let page = WikipediaPage(title: "American Broadcasting Company", pageid: 62027)
        let content = try await page.content()
//        print(content)
        XCTAssertNotEqual(content.count, 0)
    }
    
    func testWikipediaSearchLoad() async throws {
        let client = WikipediaAPIWrapper()
        let docs = try await client.load(query: "abc")
//        print(docs)
        XCTAssertEqual(docs.count, 3)
    }
    
    func testPubmedSearchAPI() async throws {
        let client = PubmedAPIWrapper()
        let pubmeds = try await client.search(query: "ai")
//        print(pubmeds)
        XCTAssertEqual(pubmeds.count, 5)
    }
    
    func testPubmedFetchPageContentAPI() async throws {
        let page = PubmedPage(uid: "37926277", webenv: "MCID_6548a476fc7406607a2fa42d")
        let content = try await page.content()
//        print(content)
//        print(content.count)
        XCTAssertNotEqual(content.count, 0)
    }
    
    func testPubmedSearchLoad() async throws {
        let client = PubmedAPIWrapper()
        let docs = try await client.load(query: "ai")
//        print(docs)
        XCTAssertEqual(docs.count, 5)
    }
    
    func testOpenWeatherAPI() async throws {
        let client = OpenWeatherAPIWrapper()
        let currentWeather = try await client.search(query: "10.99:44.34", apiKey: "7463430d465b51d78562f11033424be7")
        print(currentWeather!)
    }
    
    func testInMemoryStore() async throws {
        let store = InMemoryStore()
        await store.mset(kvpairs: [("1", "a"), ("2", "b")])
        let values = await store.mget(keys: ["1", "2"])
        XCTAssertEqual(values, ["a", "b"])
        await store.mdelete(keys: ["1"])
        let keys = await store.keys()
        XCTAssertEqual(keys, ["2"])
    }
    
    func testRecursiveCharacterTextSplitter() async throws {
        //This text splitter is used to create the parent documents
        let parent_splitter = RecursiveCharacterTextSplitter(chunk_size: 2000, chunk_overlap: 200)
        var docs = parent_splitter.split_text(text: bySplit)
        for doc in docs {
//            print(doc)
            XCTAssertTrue(doc.count <= 2000)
        }
        //This text splitter is used to create the child documents
        //It should create documents smaller than the parent
        let child_splitter = RecursiveCharacterTextSplitter(chunk_size: 400, chunk_overlap: 200)
        docs = child_splitter.split_text(text: bySplit)
        for doc in docs {
//            print(doc)
            XCTAssertTrue(doc.count <= 400)
        }
    }
    
    func testFileStore() async throws {
        let store = LocalFileStore(prefix: "+abc")
        await store.mset(kvpairs: [("1", "a"), ("2", "b")])
        let values = await store.mget(keys: ["1", "2"])
        XCTAssertEqual(values, ["a", "b"])
        await store.mdelete(keys: ["1"])
        let keys = await store.keys()
        XCTAssertEqual(keys, ["2"])
    }
    
//
//    func testYoutubeHackClientList() async throws {
//        let eventLoopGroup = ThreadManager.thread
//
//        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
//        defer {
//            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
//            try? httpClient.syncShutdown()
//        }
//        var list = await YoutubeHackClient.list_transcripts(video_id: "JdM6AruIKT4",
//                                                            httpClient: httpClient)
////        print(list.manually_created_transcripts.count)
//        XCTAssertEqual(2, list!.manually_created_transcripts.count)
//        
//        let t = list!.find_transcript(language_codes: ["zh"])
//        XCTAssertNotNil(t)
////        print(t!)
//        let dict = await t!.fetch()
////        print(dict!)
//        
//    }
//    
//    func testYoutubeHackClientTranslate() async throws {
//        let eventLoopGroup = ThreadManager.thread
//
//        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
//        defer {
//            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
//            try? httpClient.syncShutdown()
//        }
//        var list = await YoutubeHackClient.list_transcripts(video_id: "JdM6AruIKT4",
//                                                            httpClient: httpClient)
////        print(list.manually_created_transcripts.count)
//        XCTAssertEqual(2, list!.manually_created_transcripts.count)
//        
//        let t = list!.find_transcript(language_codes: ["zh"])
//        XCTAssertNotNil(t)
////        print(t!)
//        let en = t!.translate(language_code: "en")
//        let dict = await en.fetch()
////        print(dict!)
//        XCTAssertNotNil(dict)
//    }
//    
//    func testYoutubeHackClientTranslateEN() async throws {
//        let eventLoopGroup = ThreadManager.thread
//
//        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
//        defer {
//            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
//            try? httpClient.syncShutdown()
//        }
//        let list = await YoutubeHackClient.list_transcripts(video_id: "JdM6AruIKT4",
//                                                            httpClient: httpClient)
////        print(list.manually_created_transcripts.count)
//        XCTAssertEqual(2, list!.manually_created_transcripts.count)
//        
//        let t = list!.manually_created_transcripts.first!.value
////        print(t!)
//        let en = t.translate(language_code: "en")
//        let dict = await en.fetch()
////        print(dict!)
//        XCTAssertNotNil(dict)
//    }
//    
//    func testYoutubeInfoFetch() async throws {
//        let eventLoopGroup = ThreadManager.thread
//        
//        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
//        defer {
//            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
//            try? httpClient.syncShutdown()
//        }
//        
//        let info = await YoutubeHackClient.info(video_id: "JdM6AruIKT4", httpClient: httpClient)
//        
//        print(info!)
//    }
}
