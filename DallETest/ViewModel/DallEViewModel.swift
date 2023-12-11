//
//  DallEViewModel.swift
//  DallETest
//
//  Created by 김태은 on 12/5/23.
//

import Foundation

class DallEViewModel: ObservableObject {
    var openAIApiKey: String {
        guard let plistPath = Bundle.main.path(forResource: "SecureKeys", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: plistPath) else {
            fatalError("SecureKeys.plist를 찾을 수 없어요.")
        }
        
        guard let value = plistDict["OpenAI_API_KEY"] as? String else {
            fatalError("OpenAI_API_KEY를 찾을 수 없어요.")
        }
        
        return value
    }
    
    func postDallE(prompt: String, completion: @escaping (DallEModel?) -> Void) {
        let url = "https://api.openai.com/v1/images/generations"
        
        // Header 세팅
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(openAIApiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "dall-e-2",
            "prompt": prompt,
            "n": 5,
            "size": "256x256"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // API 요청
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    // if let jsonString = String(data: data, encoding: .utf8) {
                    //     print("Received JSON data: \(jsonString)")
                    // }
                    
                    // DallEModel JSON 디코드
                    let decoder = JSONDecoder()
                    let dallEModel = try decoder.decode(DallEModel.self, from: data)
                    completion(dallEModel)
                } catch {
                    print("JSON 파싱 오류: \(error.localizedDescription)")
                    completion(nil)
                }
            } else if let error = error {
                print("API 요청 중 오류: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        // API 요청 시작
        task.resume()
    }
}
