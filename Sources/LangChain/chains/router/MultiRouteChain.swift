//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/7.
//

import Foundation
public class MultiRouteChain: DefaultChain {
    let router_chain: LLMRouterChain
        
    let destination_chains: [String: DefaultChain]

    let default_chain: DefaultChain
    
    public init(router_chain: LLMRouterChain, destination_chains: [String : DefaultChain], default_chain: DefaultChain, memory: BaseMemory? = nil, outputKey: String = "output", inputKey: String = "input", callbacks: [BaseCallbackHandler] = []) {
        self.router_chain = router_chain
        self.destination_chains = destination_chains
        self.default_chain = default_chain
        super.init(memory: memory, outputKey: outputKey, inputKey: inputKey, callbacks: callbacks)
    }
    
    // call route
    public override func _call(args: String) async -> (LLMResult?, Parsed) {
//        print("call route.")
//        _run_manager = run_manager or CallbackManagerForChainRun.get_noop_manager()
//                callbacks = _run_manager.get_child()
//                route = self.router_chain.route(inputs, callbacks=callbacks)
//
//                _run_manager.on_text(
//                    str(route.destination) + ": " + str(route.next_inputs), verbose=self.verbose
//                )
//                if not route.destination:
//                    return self.default_chain(route.next_inputs, callbacks=callbacks)
//                elif route.destination in self.destination_chains:
//                    return self.destination_chains[route.destination](
//                        route.next_inputs, callbacks=callbacks
//                    )
//                elif self.silent_errors:
//                    return self.default_chain(route.next_inputs, callbacks=callbacks)
//                else:
//                    raise ValueError(
//                        f"Received invalid destination chain name '{route.destination}'"
//                    )
        let route = await self.router_chain.route(args: args)
        if destination_chains.keys.contains(route.destination) {
            return await destination_chains[route.destination]!._call(args: route.next_inputs)
        } else {
            return await default_chain._call(args: route.next_inputs)
        }
    }
}
