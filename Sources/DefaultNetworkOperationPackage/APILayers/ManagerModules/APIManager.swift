//
//  APIManager.swift
//  CartCodeCase
//
//  Created by Erkut Bas on 20.10.2020.
//

import Foundation
import Network

public class APIManager: APIManagerInterface {
    
    public static let shared = APIManager()

    // Mark: - Session -
    private let session: URLSession

    // Mark: - JsonDecoder -
    private var jsonDecoder = JSONDecoder()
    
    public init() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 300
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.session = URLSession(configuration: config)
    }
    
    public func executeRequest<R>(urlRequest: URLRequest, completion: @escaping (Result<R, ErrorResponse>) -> Void) where R : Codable {
        
        session.dataTask(with: urlRequest) { [weak self](data, urlResponse, error) in
            self?.dataTaskHandler(data, urlResponse, error, completion: completion)
        }.resume()
        
    }
    
    private func dataTaskHandler<R: Codable>(_ data: Data?, _ response: URLResponse?, _ error: Error?, completion: @escaping (Result<R, ErrorResponse>) -> Void) {
        
        if error != nil {
            // completion failure
            print("makasi : \(String(describing: error))")
        }else {
            
            if let httpResponse = response as? HTTPURLResponse {
                
                let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode)
                
                switch statusCode {
                case .ok:
                    if let data = data {
                        
                        do {

                            //print(String(data: data, encoding: .utf8) ?? "")
                            
                            let dataDecoded = try jsonDecoder.decode(R.self, from: data)
                            //print("data : \(data)")
                            
                            completion(.success(dataDecoded))
                            
                        } catch let error {
                            
                            // if it cannot decode the given model then catch and call.
                            completion(.failure(ErrorResponse.init(serverResponse: ServerResponse.init(returnMessage: "\(error.localizedDescription)", returnCode: HTTPStatusCode.ok.rawValue), apiConnectionErrorType: ApiConnectionErrorType.dataDecodedFailed(error.localizedDescription))))
                        }
                    }
                    
                case .notfound:
                    completion(.failure(ErrorResponse.init(serverResponse: ServerResponse.init(returnMessage: "Not Found!", returnCode: HTTPStatusCode.notfound.rawValue), apiConnectionErrorType: ApiConnectionErrorType.serverError(HTTPStatusCode.notfound.rawValue))))
                    
                case .unauthorized:
                    completion(.failure(ErrorResponse.init(serverResponse: ServerResponse.init(returnMessage: "Api key invalid or missing!", returnCode: HTTPStatusCode.unauthorized.rawValue))))
                default:
                    break
                }
            }
        }
    }
    
    deinit {
        print("DEINIT APIMANAGER")
    }
    
}
