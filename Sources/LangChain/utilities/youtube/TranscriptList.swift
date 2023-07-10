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

public struct TranscriptList {
    let video_id: String
    var manually_created_transcripts: [String: Transcript]
    let generated_transcripts: [String: Transcript]
    let translation_languages: [[String : String]]
//    def find_transcript(self, language_codes):
//            """
//            Finds a transcript for a given language code. Manually created transcripts are returned first and only if none
//            are found, generated transcripts are used. If you only want generated transcripts use
//            `find_manually_created_transcript` instead.
//
//            :param language_codes: A list of language codes in a descending priority. For example, if this is set to
//            ['de', 'en'] it will first try to fetch the german transcript (de) and then fetch the english transcript (en) if
//            it fails to do so.
//            :type languages: list[str]
//            :return: the found Transcript
//            :rtype Transcript:
//            :raises: NoTranscriptFound
//            """
//            return self._find_transcript(language_codes, [self._manually_created_transcripts, self._generated_transcripts])

    mutating func find_transcript(language_codes: [String] = ["en"]) -> Transcript? {
        self.manually_created_transcripts.merge(self.generated_transcripts, uniquingKeysWith: { (current, new) in new })
        
        for language_code in language_codes{
            for transcript_dict in self.manually_created_transcripts {
                if transcript_dict.key.contains(language_code){
                    return transcript_dict.value
                }
            }
        }
        return nil
    }
    static func build(http_client: HTTPClient, video_id: String, captions_json: JSON?) -> TranscriptList? {
        if captions_json == nil {
            return nil
        }
        let translation_languages = captions_json!["translationLanguages"].arrayValue.map{
            [
                "language": $0["languageName"]["simpleText"].stringValue,
                "language_code": $0["languageCode"].stringValue,
            ]
        }
        var manually_created_transcripts: [String: Transcript] = [:]
        var generated_transcripts: [String: Transcript] = [:]
        for caption in captions_json!["captionTracks"].arrayValue {
            if caption["kind"].exists() {
                generated_transcripts[caption["languageCode"].stringValue] = Transcript(
                    http_client: http_client, video_id: video_id, url: caption["baseUrl"].stringValue, language: caption["name"]["simpleText"].stringValue, language_code: caption["languageCode"].stringValue, is_generated: caption["kind"].exists() && caption["kind"].stringValue == "asr" , translation_languages: caption["isTranslatable"].exists() ? translation_languages:[]
                )
                    //                      http_client,
                    //                      video_id,
                    //                      caption['baseUrl'],
                    //                      caption['name']['simpleText'],
                    //                      caption['languageCode'],
                    //                      caption.get('kind', '') == 'asr',
                    //                      translation_languages if caption.get('isTranslatable', False) else [],
                    //                  )
            } else {
                manually_created_transcripts[caption["languageCode"].stringValue] = Transcript(
                    http_client: http_client, video_id: video_id, url: caption["baseUrl"].stringValue, language: caption["name"]["simpleText"].stringValue, language_code: caption["languageCode"].stringValue, is_generated: caption["kind"].exists() && caption["kind"].stringValue == "asr" , translation_languages: caption["isTranslatable"].exists() ? translation_languages:[]
                )
            }
        }
//        translation_languages = [
//                  {
//                      'language': translation_language['languageName']['simpleText'],
//                      'language_code': translation_language['languageCode'],
//                  } for translation_language in captions_json['translationLanguages']
//              ]
//
//              manually_created_transcripts = {}
//              generated_transcripts = {}
//
//              for caption in captions_json['captionTracks']:
//                  if caption.get('kind', '') == 'asr':
//                      transcript_dict = generated_transcripts
//                  else:
//                      transcript_dict = manually_created_transcripts
//
//                  transcript_dict[caption['languageCode']] = Transcript(
//                      http_client,
//                      video_id,
//                      caption['baseUrl'],
//                      caption['name']['simpleText'],
//                      caption['languageCode'],
//                      caption.get('kind', '') == 'asr',
//                      translation_languages if caption.get('isTranslatable', False) else [],
//                  )
//
//              return TranscriptList(
//                  video_id,
//                  manually_created_transcripts,
//                  generated_transcripts,
//                  translation_languages,
//              )
        return TranscriptList(video_id: video_id, manually_created_transcripts: manually_created_transcripts, generated_transcripts: generated_transcripts, translation_languages: translation_languages)
    }
//    def build(http_client, video_id, captions_json):
//            """
//            Factory method for TranscriptList.
//
//            :param http_client: http client which is used to make the transcript retrieving http calls
//            :type http_client: requests.Session
//            :param video_id: the id of the video this TranscriptList is for
//            :type video_id: str
//            :param captions_json: the JSON parsed from the YouTube pages static HTML
//            :type captions_json: dict
//            :return: the created TranscriptList
//            :rtype TranscriptList:
//            """
//            translation_languages = [
//                {
//                    'language': translation_language['languageName']['simpleText'],
//                    'language_code': translation_language['languageCode'],
//                } for translation_language in captions_json['translationLanguages']
//            ]
//
//            manually_created_transcripts = {}
//            generated_transcripts = {}
//
//            for caption in captions_json['captionTracks']:
//                if caption.get('kind', '') == 'asr':
//                    transcript_dict = generated_transcripts
//                else:
//                    transcript_dict = manually_created_transcripts
//
//                transcript_dict[caption['languageCode']] = Transcript(
//                    http_client,
//                    video_id,
//                    caption['baseUrl'],
//                    caption['name']['simpleText'],
//                    caption['languageCode'],
//                    caption.get('kind', '') == 'asr',
//                    translation_languages if caption.get('isTranslatable', False) else [],
//                )
//
//            return TranscriptList(
//                video_id,
//                manually_created_transcripts,
//                generated_transcripts,
//                translation_languages,
//            )

}
