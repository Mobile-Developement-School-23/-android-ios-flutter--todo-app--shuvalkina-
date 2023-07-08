
import Foundation
import Atomics

protocol NetworkingService {
    func loadAll() async throws -> [ServerItem]
//    Получить список с сервера
//    GET $BASEURL/list
    func updateAll(itemsToUpdate: [ServerItem]) async throws -> [ServerItem]
//    Обновить список на сервере
//    PATCH $BASEURL/list
    func downloadItem(downloadForItemId: String) async throws -> ServerItem?
//    Получить элемент списка
//    GET $BASEURL/list/<id>
    func uploadItem(itemToUpload: ServerItem) async throws -> ServerItem
//    Добавить элемент списка
//    POST $BASEURL/list
    func updateItem(updateForItemId: String) async throws -> ServerItem?
//    Изменить элемент списка
//    PUT $BASEURL/list/<id>
    func deleteItem(deleteForItemId: String) async throws -> ServerItem?
//    Удалить элемент списка
//    DELETE $BASEURL/list/<id>
}

enum Hand: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

////______________________________________________________
//400 - неправильно сформирован запрос
//не хватает частей урла или заголовков
//не совпадают известная ревизия на сервере и то что передано (unsynchronizedData)
//401 - неверная авторизация
//404 - такого элемента на сервере не найден
//500 - какая-то ошибка сервера

enum RequestError: Error {
    case badRequest
    case badAuthorization
    case itemNotFound
    case serverError
    case horrorError
}
extension RequestError {
    fileprivate var description: String {
        switch self {
        case .badRequest:
            return "400 - неправильно сформирован запрос"
        case .badAuthorization:
            return "401 - неверная авторизация"
        case .itemNotFound:
            return "404 - такого элемента на сервере не найден"
        case .serverError:
            return "500 - какая-то ошибка сервера"
        case .horrorError:
            return "неизвестная ошибка"
        }
    }
}
private func Response(code: Int) throws {
    switch code {
    case 200..<300:
        return
    case 400:
        throw RequestError.badRequest
    case 401:
        throw RequestError.badAuthorization
    case 404:
        throw RequestError.itemNotFound
    case 500..<600:
        isDirty = true
        throw RequestError.serverError
    default:
        return
    }
}

var isDirty: Bool = false
let token: String = "dispericraniate"
var revision: Int32 = 0
var baseURL = URLComponents(string: "https://beta.mrdekk.ru/todobackend/list")
var id = "Shuvalkina_E"
var data: Data?
struct DefaultNetworkingService {
    
    
    
    func loadAll() async throws -> [ServerItem] {
        var GETrequest = URLRequest(url: (baseURL?.url)!)
        GETrequest.httpMethod = "GET"
        GETrequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: GETrequest)
        try Response(code: (response as? HTTPURLResponse)?.statusCode ?? 0)
//        return data as! [ServerItem]
    
        }
    }
    
    func updateAll(itemsToUpdate: [ServerItem]) async throws -> [ServerItem] {
            var PATCHrequest = URLRequest(url: (baseURL?.url)!)
            PATCHrequest.httpMethod = "PATCH"
            PATCHrequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            PATCHrequest.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
//            PATCHrequest.httpBody = itemsToUpdate  as! Data
        }
    
    func downloadItem(downloadForItemId: String) async throws -> ServerItem? {
//        var GETrequest = URLRequest(url: (baseURL?.url)!)
//        GETrequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return 
        }
    
    
    func uploadItem(itemToUpload: ServerItem) async throws -> ServerItem {
            var POSTrequest = URLRequest(url: (baseURL?.url)!)
            POSTrequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            POSTrequest.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
            POSTrequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            POSTrequest.setValue("application/json", forHTTPHeaderField: "Accept")
//            POSTrequest.httpBody = itemToUpload as! Data?
        }
    
    func updateItem(updateForItemId: String) async throws -> ServerItem? {
            var PUTrequest = URLRequest(url: (baseURL?.url)!)
            PUTrequest.httpMethod = "PUT"
            PUTrequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

func deleteItem(deleteForItemId: String) async throws -> ServerItem? {
    var DELETErequest = URLRequest(url: (baseURL?.url)!)
    DELETErequest.httpMethod = "DELETE"
    DELETErequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    DELETErequest.setValue("application/json", forHTTPHeaderField: "Accept")
}
    






