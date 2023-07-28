//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/7/28.
//

import Foundation
import PDFKit

//if let url = Bundle.main.url(forResource: "sample_pdf", withExtension: "pdf") {
//
//}
public struct PDFLoader: BaseLoader {
    let fileURL: URL
    
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    public func load() async -> [Document] {
        if let pdfDocument = PDFDocument(url: fileURL) {
            var extractedText = ""
            let metadata = ["url": fileURL.absoluteString]
            for pageIndex in 0 ..< pdfDocument.pageCount {
                if let pdfPage = pdfDocument.page(at: pageIndex) {
                    if let pageInfo = pdfPage.string {
                        extractedText += pageInfo
                    }
                 
                }
            }
            
            print(extractedText)
            return [Document(page_content: extractedText, metadata: metadata)]
        } else{
            return []
        }
    }
    
}
