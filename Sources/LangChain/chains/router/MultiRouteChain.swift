//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/7.
//

import Foundation
public class MultiRouteChain: DefaultChain {
    // call route
    public override func call(args: String) async throws -> String {
        print("call route.")
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
        return args
    }
}
