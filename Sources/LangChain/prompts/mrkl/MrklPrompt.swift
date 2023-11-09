//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/16.
//

import Foundation
//# flake8: noqa
public let PREFIX = """
Answer the following questions as best you can. You have access to the following tools:
"""
public let FORMAT_INSTRUCTIONS = """
Use the following format:

Question: the input question you must answer
Thought: you should always think about what to do
Action: the action to take, should be one of [%@]
Action Input: the input to the action
Observation: the result of the action
... (this Thought/Action/Action Input/Observation can repeat N times)
Thought: I now know the final answer
Final Answer: the final answer to the original input question
"""
public let SUFFIX = """
Begin!

Question: {question}
Thought: {thought}
"""

public let FINAL_ANSWER_ACTION = "FINAL ANSWER"
