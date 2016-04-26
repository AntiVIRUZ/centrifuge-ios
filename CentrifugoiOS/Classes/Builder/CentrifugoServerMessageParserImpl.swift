//
//  CentrifugoServerMessageParserImpl.swift
//  Pods
//
//  Created by Herman Saprykin on 19/04/16.
//
//

protocol CentrifugoServerMessageParser {
    func parse(data: NSData) throws -> [CentrifugoServerMessage]
}

class CentrifugoServerMessageParserImpl: CentrifugoServerMessageParser {
    func parse(data: NSData) throws -> [CentrifugoServerMessage] {        
        do {
            let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
            var messages = [CentrifugoServerMessage]()
            
            if let infos = response as? [[String : AnyObject]] {
                for info in infos {
                    if let message = messageParse(info){
                        messages.append(message)
                    }
                }
            }
            
            if let info = response as? [String : AnyObject] {
                if let message = messageParse(info){
                    messages.append(message)
                }
            }
            
            return messages
            
        }catch {
            //TODO: add error thrown
            assertionFailure("Error: Invalid message json")
            return []
        }
    }
    
    func messageParse(info: [String : AnyObject]) -> CentrifugoServerMessage? {
        guard let uid = info["uid"] as? String? else {
            print("Error: Invalid server response: Not valid message format")
            print(info)
            return nil
        }
        
        guard let methodName = info["method"] as? String else {
            print("Error: Invalid server response: Not valid message format")
            print(info)
            return nil
        }
        
        guard let method = CentrifugoMethod(rawValue: methodName) else {
            print("Error: Invalid server response: Not valid message format")
            print(info)
            return nil
        }
        var error: String?
        
        if let err = info["error"] as? String {
            error = err
        }
        
        var body: [String: AnyObject]?
        
        if let bd = info["body"] as? [String : AnyObject] {
            body = bd
        }
        
        return CentrifugoServerMessage(uid: uid, method: method, error: error, body: body)
    }
}