import UIKit

class APIManager {

    static let shared = APIManager()
    let baseURL = "https://github.com/RitikPal98/DPbackend"

    func fetchData(endpoint: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                completion(.success(data))
            }
        }
        task.resume()
    }
}
