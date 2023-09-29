import Foundation
import CommonCrypto

class Cryptor {
    
    static func hmac(string: String, algorithm: Algorithm, key: String) -> String? {
        guard let key = key.data(using: .utf8) else { return nil }
        guard let string = string.data(using: .utf8) else { return nil }
        
        let context = UnsafeMutablePointer<CCHmacContext>.allocate(capacity: 1)
        defer { context.deallocate() }
        
        key.withUnsafeBytes { (buffer: UnsafePointer<UInt8>) in
            CCHmacInit(context, algorithm.HMACAlgorithm, buffer, size_t(key.count))
        }

        string.withUnsafeBytes { (buffer: UnsafePointer<UInt8>) in
          CCHmacUpdate(context, buffer, size_t(string.count))
        }

        var hmac = Array<UInt8>(repeating: 0, count: Int(algorithm.digestLength))
        CCHmacFinal(context, &hmac)

        return Data(hmac).base64URLEncodedString()
    }

    enum Algorithm {
        case MD5, SHA1, SHA224, SHA256, SHA384, SHA512

        var HMACAlgorithm: CCHmacAlgorithm {
            var result: Int = 0
            switch self {
            case .MD5:      result = kCCHmacAlgMD5
            case .SHA1:     result = kCCHmacAlgSHA1
            case .SHA224:   result = kCCHmacAlgSHA224
            case .SHA256:   result = kCCHmacAlgSHA256
            case .SHA384:   result = kCCHmacAlgSHA384
            case .SHA512:   result = kCCHmacAlgSHA512
            }
            return CCHmacAlgorithm(result)
        }

        var digestLength: Int {
            var result: Int32 = 0
            switch self {
            case .MD5:      result = CC_MD5_DIGEST_LENGTH
            case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
            case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
            case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
            case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
            case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
            }
            return Int(result)
        }
    }
}


