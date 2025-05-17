import Foundation

// MARK: - URLSession Protocols for Mocking

protocol URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

// Conform URLSession to URLSessionProtocol
extension URLSession: URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return (dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask)
    }
}

// Conform URLSessionDataTask to URLSessionDataTaskProtocol
extension URLSessionDataTask: URLSessionDataTaskProtocol {} 