//
//  File.swift
//  
//
//  Created by 顾艳华 on 1/22/24.
//

import Foundation
import llmfarm_core
import llmfarm_core_cpp

public class Local {
    
    public init() {
    }
    
    public func _send(text: String, stops: [String] = []) async throws -> LLMResult {
        print("Hello.")
        var input_text = "State the meaning of life."
        var modelInference:ModelInference
        var ai = AI(_modelPath: "/Users/guyanhua/llama-2-7b-chat.Q3_K_S.gguf",_chatName: "chat")
        modelInference = ModelInference.LLama_gguf
        var params:ModelAndContextParams = .default
        params.context = 4095
        params.n_threads = 14
        //
        params.use_metal = false
        
        do{
            try ai.loadModel(modelInference,contextParams: params)
            var output=""
            try ExceptionCather.catchException {
                output = try! ai.model.predict(input_text, mainCallback)
            }
            //    llama_save_session_file(ai.model.context,"/Users/guinmoon/dev/alpaca_llama_etc/dump_state.bin",ai.model.session_tokens, ai.model.session_tokens.count)
            //    llama_save_state(ai.model.context,"/Users/guinmoon/dev/alpaca_llama_etc/dump_state_.bin")
            //
            print(output)
        }catch {
            print (error)
        }
        return LLMResult()
    }
    
    func mainCallback(_ str: String, _ time: Double) -> Bool {
        print("\(str)",terminator: "")

        return false
    }
}

