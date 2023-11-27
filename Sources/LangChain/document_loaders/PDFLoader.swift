//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/7/28.
//

import Foundation
import PDFKit


public class PDFLoader: BaseLoader {
    let file_path: URL
    
    public init(file_path: URL, callbacks: [BaseCallbackHandler] = []) {
        self.file_path = file_path
        super.init(callbacks: callbacks)
    }
    
    public override func _load() async throws -> [Document] {
//        let nameAndExt = self.file_path.split(separator: ".")
//        let name = "\(nameAndExt[0])"
//        let ext = "\(nameAndExt[1])"
//        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
        if let pdfDocument = PDFDocument(url: file_path) {
                var extractedText = ""
            let metadata = ["source": file_path.absoluteString]
                for pageIndex in 0 ..< pdfDocument.pageCount {
                    if let pdfPage = pdfDocument.page(at: pageIndex) {
                        if let pageContent = pdfPage.attributedString {
                            let pageString = pageContent.string
                            extractedText += "\n\(pageString)"
//                            print("💼\(pageContent)")
//                            print("🖥️\(pageString)")
                        }
                    }
                }
                
    //            print(extractedText)
                return [Document(page_content: extractedText, metadata: metadata)]
            } else{
                throw LangChainError.LoaderError("Parse PDF file fail.")
            }
//        } else {
//            throw LangChainError.LoaderError("PDF not exist")
//        }
    }
    
    override func type() -> String {
        "PDF"
    }
}
