import Foundation
import CoreData

struct TodoItem: Codable {
    let id: String
    let text: String
    let priority: Priority
    let deadline: Int?
    let done: Bool
    let whenCreated: Int
    let whenEdited: Int?
    enum Priority: String, Codable {
        case minor = "неважная", common = "обычная", major = "важная"
    }
    init (
        id: String = UUID().uuidString,
        text: String,
        priority: Priority,
        deadline: Int?,
        done: Bool,
        whenCreated: Int,
        whenEdited: Int?
    ) {
        self.id = id
        self.text = text
        self.priority = priority
        self.deadline = deadline
        self.done = done
        self.whenCreated = whenCreated
        self.whenEdited = whenEdited
    }
}

// MARK: - JSON методы

extension TodoItem {
    var json: Any {
        var dictionary: [String: Any] = [
            "id": id,
            "text": text,
            "done": done,
            "whenCreated": whenCreated
        ]
        if priority != .common {
            dictionary["priority"] = priority.rawValue
        }
        if let whenEdited {
            dictionary["whenEdited"] = whenEdited
        }
        if let deadline {
            dictionary["deadline"] = Int(deadline)
        }
        return dictionary
    }
    static func parseJSON(json: Any) -> TodoItem? {
        guard let json = json as? [String: Any]
        else {
            print("ошибка каста JSON")
            return nil
        }
        guard
        let id = json["id"] as? String,
        let text = json["text"] as? String,
        let deadline = json["deadline"] as? Int?,
        let done = json["done"] as? Bool,
        let whenCreated = json["whenCreated"] as? Int,
        let whenEdited = json["whenEdited"] as? Int
        else {
            print("ошибка распаковки опциональных значений")
            return nil
        }
        var priority = Priority.common
        if !(((json["priority"] as? String)?.isEmpty) == nil) {
            // swiftlint:disable:next force_cast
            let priorityString = json["priority"] as! String
            priority = Priority(rawValue: priorityString)!
        }
        let todoData = TodoItem(
            id: id,
            text: text,
            priority: priority,
            deadline: deadline,
            done: done,
            whenCreated: whenCreated,
            whenEdited: whenEdited )
        return todoData
    }
}

// MARK: - СSV методы

extension TodoItem {
    var csv: String {
        var csvString = "\("id"),\("text"),\("priority"),\("deadline"),\("done"),\("whenCreated"),\("whenEdited")\n\n"
        // перенос вспомогательных параметров задания в строку
        var optionals = [String(priority.rawValue), String(deadline ?? 0), String(whenEdited ?? 0)]
        if priority == .common {
            optionals[0] = ""
        }
        if deadline == nil {
            optionals[1] = ""
        }
        if whenEdited == nil {
            optionals[2] = ""
        }
        let itemString = "\(id),\(text),\(optionals[0]),\(optionals[1]),\(String(done)),\(String(whenCreated)),\(optionals[2])\n"
        csvString.append(itemString)
        return csvString
    }
    static func parse(csv: String) -> TodoItem? {
        let todoString = csv.components(separatedBy: ",")
        guard
            todoString.count == 7
        else {
            print("oшибка распаковки csv")
            return nil
        }
        let priorityString = Priority(rawValue: todoString[3]) ?? .common
        let done = NSString(string: todoString[4]).boolValue
        let whenEdited = Int(todoString[7])
        let todoData = TodoItem(
            id: todoString[0],
            text: todoString[1],
            priority: priorityString,
            deadline: Int(todoString[4]),
            done: done, whenCreated:
                Int(todoString[6])!,
            whenEdited: whenEdited ?? nil )
            return todoData
    }
}
//
