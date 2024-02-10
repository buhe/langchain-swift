import llmfarm_core
import Foundation

public class Local: LLM {
    let modelPath: String
    let useMetal: Bool
    let inference: ModelInference
    var params: ModelAndContextParams
    var sampleParams: ModelSampleParams
    
    public init(inference: ModelInference, modelPath: String, useMetal: Bool = false,params: ModelAndContextParams = .default, sampleParams: ModelSampleParams = .default, callbacks: [BaseCallbackHandler] = [], cache: BaseCache? = nil) {
        self.inference = inference
        self.modelPath = modelPath
        self.useMetal = useMetal
        self.params = params
        self.sampleParams = sampleParams
        super.init(callbacks: callbacks, cache: cache)
    }
    public override func _send(text: String, stops: [String] = []) async throws -> LLMResult {
        let ai = AI(_modelPath: self.modelPath, _chatName: "chat")
        self.params.use_metal = useMetal
        
        let _ = try? ai.loadModel(inference, contextParams: self.params)
        ai.model.sampleParams = self.sampleParams
        let output = try? ai.model.predict(text, mainCallback)
//        print("🚗\(output)")
        total_output = 0
        return LLMResult(llm_output: output)
    }
    
    let maxOutputLength = 256
    var total_output = 0

    func mainCallback(_ str: String, _ time: Double) -> Bool {
        print("\(str)",terminator: "")
        total_output += str.count
        if(total_output>maxOutputLength){
            return true
        }
        return false
    }
}
