import UIKit
import Foundation
import Atomics

protocol NetworkingService {
    func loadAll() async throws -> [ServerItem]
//    Получить список с сервера
//    GET $BASEURL/list
    func updateAll(itemsToUpdate: [TodoItem]) async throws -> [ServerItem]
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


struct DefaultNetworkingService {
    
    private mutating func Response(code: Int) throws {
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
    var revision: Int = 0
    var baseURL = URLComponents(string: "https://beta.mrdekk.ru/todobackend/list")
    var id = "Shuvalkina_E"
    var data: Data?
    
    mutating func loadAll() async throws -> [TodoItem] {
        let url = URL(string: "https://beta.mrdekk.ru/todobackend/list")!
        var GETrequest = URLRequest(url: url)
        GETrequest.httpMethod = "GET"
        GETrequest.setValue("Bearer dispericraniate", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: GETrequest)
        try Response(code: (response as? HTTPURLResponse)?.statusCode ?? 0)
        let serverData = try JSONDecoder().decode(ServerResponse.self, from: data)
        if let revision = serverData.revision {
            self.revision = revision
        }
        isDirty = false
        return serverData.list.map { convertFromServer($0) }
        
    }
    
    
    mutating func updateAll(itemsToUpdate: [TodoItem]) async throws -> [TodoItem] {
        let url = URL(string: "https://beta.mrdekk.ru/todobackend/list")!
        let serverItems = ServerResponse(list: itemsToUpdate.map({ convertToServer($0) }))
        let dataForServer = try JSONEncoder().encode(serverItems)
        var PATCHrequest = URLRequest(url: url)
        PATCHrequest.httpMethod = "PATCH"
        PATCHrequest.setValue("Bearer dispericraniate", forHTTPHeaderField: "Authorization")
        PATCHrequest.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
        PATCHrequest.httpBody = dataForServer
        let (data, response) = try await URLSession.shared.data(for: PATCHrequest)
        try Response(code: (response as? HTTPURLResponse)?.statusCode ?? 0)
        let serverData = try JSONDecoder().decode(ServerResponse.self, from: data)
        isDirty = false
        if let revision = serverData.revision {
            self.revision = revision
        }
        return serverData.list.map { convertFromServer($0) }
    }
    
    
    mutating func downloadItem(downloadForItemId: String) async throws -> TodoItem? {
//        mutating func downloadItem(downloadForItemId: String) async throws -> ServerItem? {
        let url = URL(string: "https://beta.mrdekk.ru/todobackend/list")!
        var GETrequest = URLRequest(url: url)
        GETrequest.httpMethod = "GET"
        GETrequest.setValue("Bearer dispericraniate", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: GETrequest)
        try Response(code: (response as? HTTPURLResponse)?.statusCode ?? 0)
        let serverData = try JSONDecoder().decode(ServerResponse.self, from: data)
        if let revision = serverData.revision {
            self.revision = revision
        }
        isDirty = false
        return convertFromServer (serverData.list[0] )
        
    }
    
    mutating func uploadItem(itemToUpload: ServerItem) async throws -> TodoItem {
        let url = URL(string: "https://beta.mrdekk.ru/todobackend/list")!
        var POSTrequest = URLRequest(url: url)
        POSTrequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        POSTrequest.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
        POSTrequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        POSTrequest.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: POSTrequest)
        try Response(code: (response as? HTTPURLResponse)?.statusCode ?? 0)
        let serverData = try JSONDecoder().decode(ServerResponse.self, from: data)
        if let revision = serverData.revision {
            self.revision = revision
        }
        isDirty = false
        return convertFromServer (serverData.list[0] )
        
    }
    
    mutating func updateItem(itemToUpdate: TodoItem) async throws -> TodoItem? {
//        func updateItem(updateForItemId: String) async throws -> ServerItem? {
        let url = URL(string: "https://beta.mrdekk.ru/todobackend/list")!
        var PUTrequest = URLRequest(url: url)
        PUTrequest.httpMethod = "PUT"
        PUTrequest.setValue("Bearer dispericraniate", forHTTPHeaderField: "Authorization")
//        let serverItem = try JSONEncoder().encode(convertToServer(itemToUpdate))
        let (data, response) = try await URLSession.shared.data(for: PUTrequest)
        try Response(code: (response as? HTTPURLResponse)?.statusCode ?? 0)
        let serverData = try JSONDecoder().decode(ServerResponse.self, from: data)
        if let revision = serverData.revision {
            self.revision = revision
        }
        return convertFromServer(serverData.list[0])
    }
    
    mutating func deleteItem(itemToDelete: TodoItem) async throws -> TodoItem? {
//        func deleteItem(deleteForItemId: String) async throws -> ServerItem? {
        let url = URL(string: "https://beta.mrdekk.ru/todobackend/list")!
        var DELETErequest = URLRequest(url: url)
        DELETErequest.httpMethod = "DELETE"
        DELETErequest.setValue("Bearer dispericraniate", forHTTPHeaderField: "Authorization")
        DELETErequest.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: DELETErequest)
        try Response(code: (response as? HTTPURLResponse)?.statusCode ?? 0)
        let serverData = try JSONDecoder().decode(ServerResponse.self, from: data)
        if let revision = serverData.revision {
            self.revision = revision
        }
        return convertFromServer(serverData.list[0])
    }
    
    
    
}



