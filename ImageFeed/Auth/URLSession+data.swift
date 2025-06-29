//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Сергей Розов on 12.06.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if
                let data,
                let response,
                let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if (200..<300).contains(statusCode) {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("❌ [URLSession.data]: HTTPStatusCodeError - код ошибки: \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error {
                print("❌ [URLSession.data]: URLRequestError - ошибка: \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("❌ [URLSession.data]: URLSessionError - неизвестная ошибка URLSession")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask {
        let decoder = JSONDecoder()
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("❌ [URLSession.objectTask]: Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ [URLSession.objectTask]: NetworkError - ошибка: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}
