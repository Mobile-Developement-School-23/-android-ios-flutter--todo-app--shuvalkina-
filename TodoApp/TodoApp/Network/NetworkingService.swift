
import Foundation
import Atomics


enum Errors: Error {
    case badDataOrResponse
    case badData
}

final class TaskState: Sendable {
    let protectedIsRunning = ManagedAtomic<Bool>(true)
    var isRunning: Bool {
        get { protectedIsRunning.load(ordering: .acquiring) }
        set { protectedIsRunning.store(newValue, ordering: .relaxed) }
    }
    func cancel() { isRunning = false }
}

extension URLSession {
        func dataTaskThrowing(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
            let state = TaskState()
            var task: URLSessionTask?
            return try await withTaskCancellationHandler(operation: {
                guard state.isRunning else {
                    throw (didFail())
                }
                return try await withCheckedThrowingContinuation { continuation in
                                 task = dataTask(with: urlRequest) { (data, response, error) in
                                    if error != nil {
                                        continuation.resume(throwing: error!)
                                    }
                                    guard let safeData = data, let safeResponse = response else {
                                       return continuation.resume(throwing: Errors.badDataOrResponse)
                                        
                                    }
                                     if let safeData = data as Data? {
                                         continuation.resume(returning: (safeData, safeResponse))
                                     } else {
                                         continuation.resume(throwing: Errors.badData)
                                        
                                     }
                                }
                    task?.resume()
                            }

            }, onCancel: {[weak task] in
                task?.cancel()
                return
            })
        }
    }


extension URLSession: URLManagerDelegate {
    
    func didFail() -> Error {
        return NSError(domain:"", code: 0, userInfo:[ NSLocalizedDescriptionKey: "Task has been canceled"]) as Error
    }
    
}
