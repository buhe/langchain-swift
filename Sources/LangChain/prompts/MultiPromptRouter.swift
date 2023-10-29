//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/7.
//

import Foundation

public struct MultiPromptRouter {
    public static func formatDestinations(destinations: String) -> String {
        """
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
        \(destinations)

        << INPUT >>
        {input}

        << OUTPUT >>
        """
    }
    
//    public static func formatInput(rawString: String, input: String) -> String {
//        let newString = rawString.replacingOccurrences(of: "%input", with: "%@")
//        return String(format: newString, input)
//    }
}
