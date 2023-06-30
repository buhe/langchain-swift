//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/30.
//

import AsyncHTTPClient
import Foundation
import NIOPosix
import SWXMLHash

struct Transcript {
    let http_client: HTTPClient
    let video_id: String
    let url: String
    let language: String
    let language_code: String
    let is_generated: Bool
    let translation_languages: [[String: String]]
    var translation_languages_dict: [String: String]
    init(http_client: HTTPClient, video_id: String, url: String, language: String, language_code: String, is_generated: Bool, translation_languages: [[String : String]]) {
        self.http_client = http_client
        self.video_id = video_id
        self.url = url
        self.language = language
        self.language_code = language_code
        self.is_generated = is_generated
        self.translation_languages = translation_languages
//        self._translation_languages_dict = {
//                    translation_language['language_code']: translation_language['language']
//                    for translation_language in translation_languages
//                }
        self.translation_languages_dict = [:]
        for t in self.translation_languages {
            self.translation_languages_dict[t["language_code"]!] = t["language"]
        }
    }
    func translate(language_code: String) -> Transcript {
        return Transcript(
                            http_client: self.http_client,
                            video_id: self.video_id,
                            url: String(format: "%@&tlang=%@", self.url, language_code),
                            language: self.translation_languages_dict[language_code]!,//self._translation_languages_dict[language_code],
                            language_code: language_code,
                            is_generated: true,
                            translation_languages: []
                        )
    }
    
    func fetch() async -> [[String: String]]? {
        do {
            var request = HTTPClientRequest(url: self.url)
            request.method = .GET
            request.headers.add(name: "Accept-Language", value: "en-US")

            let response = try await http_client.execute(request, timeout: .seconds(30))
            if response.status == .ok {
                let plain = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
                return _TranscriptParser().parse(plain_data: plain)
            } else {
                // handle remote error
                print("http code is not 200.")
                return nil
            }
        } catch {
            // handle error
            print(error)
            return nil
        }
    }
}


struct _TranscriptParser {
    func parse(plain_data: String) -> [[String: String]] {
        let xml = XMLHash.parse(plain_data)
        let textArray = xml["transcript"]["text"]
        var texts: [[String: String]] = []
        for text in textArray.all {
            let start = text.element!.attribute(by: "start")!.text
            let dur = text.element!.attribute(by: "dur")!.text
            let t = text.element!.text
            texts.append([
                "start": start,
                "dur": dur,
                "text": t,
            ])
            
        }
        return texts
    }
}
