//
//  SwiftLLM.swift
//
//
//  Created by Alec Dusheck on 7/16/24.
//

import Foundation

public class LLMSwift: LLM {
    var llm: SwiftLLMWrapper
    
    public init(
        from path: String,
        stopSequence: String? = nil,
        history: [SwiftLLMChat] = [],
        seed: UInt32 = .random(in: .min ... .max),
        topK: Int32 = 40,
        topP: Float = 0.95,
        temp: Float = 0.8,
        historyLimit: Int = 8,
        maxTokenCount: Int32 = 2048,
        callbacks: [BaseCallbackHandler] = [],
        cache: BaseCache? = nil
    ) {
        self.llm = SwiftLLMWrapper(
            from: path,
            stopSequence: stopSequence,
            history: history,
            seed: seed,
            topK: topK,
            topP: topP,
            temp: temp,
            historyLimit: historyLimit,
            maxTokenCount: maxTokenCount
        )
        super.init(callbacks: callbacks, cache: cache)
    }
    
    public convenience init(
        from url: URL,
        stopSequence: String? = nil,
        history: [SwiftLLMChat] = [],
        seed: UInt32 = .random(in: .min ... .max),
        topK: Int32 = 40,
        topP: Float = 0.95,
        temp: Float = 0.8,
        historyLimit: Int = 8,
        maxTokenCount: Int32 = 2048,
        callbacks: [BaseCallbackHandler] = [],
        cache: BaseCache? = nil
    ) {
        self.init(
            from: url.path,
            stopSequence: stopSequence,
            history: history,
            seed: seed,
            topK: topK,
            topP: topP,
            temp: temp,
            historyLimit: historyLimit,
            maxTokenCount: maxTokenCount,
            callbacks: callbacks,
            cache: cache
        )
    }
    
    public convenience init(
        from huggingFaceModel: HuggingFaceModel,
        to url: URL = .documentsDirectory,
        as name: String? = nil,
        history: [SwiftLLMChat] = [],
        seed: UInt32 = .random(in: .min ... .max),
        topK: Int32 = 40,
        topP: Float = 0.95,
        temp: Float = 0.8,
        historyLimit: Int = 8,
        maxTokenCount: Int32 = 2048,
        updateProgress: @escaping (Double) -> Void = { print(String(format: "downloaded(%.2f%%)", $0 * 100)) },
        callbacks: [BaseCallbackHandler] = [],
        cache: BaseCache? = nil
    ) async throws {
        let wrapper = try await SwiftLLMWrapper(
            from: huggingFaceModel,
            to: url,
            as: name,
            history: history,
            seed: seed,
            topK: topK,
            topP: topP,
            temp: temp,
            historyLimit: historyLimit,
            maxTokenCount: maxTokenCount,
            updateProgress: updateProgress
        )
        self.init(
            from: url.appendingPathComponent(name ?? huggingFaceModel.name).path,
            stopSequence: huggingFaceModel.template.stopSequence,
            history: history,
            seed: seed,
            topK: topK,
            topP: topP,
            temp: temp,
            historyLimit: historyLimit,
            maxTokenCount: maxTokenCount,
            callbacks: callbacks,
            cache: cache
        )
        self.llm = wrapper
    }
    
    public override func _send(text: String, stops: [String] = []) async throws -> LLMResult {
        await llm.respond(to: text)
        return LLMResult(llm_output: llm.output)
    }
}
