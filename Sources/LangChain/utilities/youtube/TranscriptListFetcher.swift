//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/30.
//

import AsyncHTTPClient
import Foundation
import NIOPosix
import SwiftyJSON

let WATCH_URL = "https://www.youtube.com/watch?v=%@"

struct TranscriptListFetcher {
    let http_client: HTTPClient
    
    init(http_client: HTTPClient) {
        self.http_client = http_client
    }
    
    func fetch(video_id: String) async -> TranscriptList? {
        return await TranscriptList.build(http_client:
                    self.http_client, video_id: video_id, captions_json: self._extract_captions_json(html: self._fetch_video_html(video_id: video_id), video_id: video_id)
                )
    }
    
    func _extract_captions_json(html: String, video_id: String) async -> JSON? {
        let splitted_html = html.components(separatedBy: "\"captions\":")
        if splitted_html.count != 2 {
            return nil
        }
        let details = splitted_html[1].components(separatedBy: ",\"videoDetails")
        let _2 = details[0].replacingOccurrences(of: "\n", with: "")
//        print(_2)
        let json = try! JSON(data:
                                _2.data(using: .utf8)!
                   )
        let captions_json = json["playerCaptionsTracklistRenderer"]
        return captions_json
    }
//    def _extract_captions_json(self, html, video_id):
//           splitted_html = html.split('"captions":')
//
//           if len(splitted_html) <= 1:
//               if video_id.startswith('http://') or video_id.startswith('https://'):
//                   raise InvalidVideoId(video_id)
//               if 'class="g-recaptcha"' in html:
//                   raise TooManyRequests(video_id)
//               if '"playabilityStatus":' not in html:
//                   raise VideoUnavailable(video_id)
//
//               raise TranscriptsDisabled(video_id)
//
//           captions_json = json.loads(
//               splitted_html[1].split(',"videoDetails')[0].replace('\n', '')
//           ).get('playerCaptionsTracklistRenderer')
//           if captions_json is None:
//               raise TranscriptsDisabled(video_id)
//
//           if 'captionTracks' not in captions_json:
//               raise NoTranscriptAvailable(video_id)
//
//           return captions_json
    
//    def _fetch_video_html(self, video_id):
//          html = self._fetch_html(video_id)
//          if 'action="https://consent.youtube.com/s"' in html:
//              self._create_consent_cookie(html, video_id)
//              html = self._fetch_html(video_id)
//              if 'action="https://consent.youtube.com/s"' in html:
//                  raise FailedToCreateConsentCookie(video_id)
//          return html
//
//      def _fetch_html(self, video_id):
//          response = self._http_client.get(WATCH_URL.format(video_id=video_id), headers={'Accept-Language': 'en-US'})
//          return unescape(_raise_http_errors(response, video_id).text)
    func _fetch_video_html(video_id: String) async -> String {
        let html = await self._fetch_html(video_id: video_id)
        return html
    }
    
    func _fetch_html(video_id: String) async -> String {
        do {
            var request = HTTPClientRequest(url: String(format: WATCH_URL, video_id))
            request.method = .GET
            request.headers.add(name: "Accept-Language", value: "en-US")

            let response = try await http_client.execute(request, timeout: .seconds(30))
            if response.status == .ok {
                return String(buffer: try await response.body.collect(upTo: 1024 * 1024))
            } else {
                // handle remote error
                print("get list http code is not 200.\(response.body)")
                return "Bad requset."
            }
        } catch {
            // handle error
            print(error)
            return "Bad request."
        }
    }
}
