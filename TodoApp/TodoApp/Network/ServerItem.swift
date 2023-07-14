

import Foundation

struct ServerItem: Codable {
    let id: String
    let text: String
    let importance: serverPriority
    let deadline: Int64?
    let done: Bool
    let color : String?
    let created_at: Int64
    let changed_at: Int64?
    let last_updated_by: String
    
    init (
        id: String,
        text: String,
        importance: serverPriority,
        deadline: Int64? = nil,
        done: Bool,
        color: String,
        created_at: Int64,
        changed_at: Int64?,
        last_updated_by: String
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.done = done
        self.color = color
        self.created_at = created_at
        self.changed_at = changed_at
        self.last_updated_by = last_updated_by
    }
}
enum serverPriority: String, Codable {
    case minor = "low", common = "basic", major = "important"
}

func convertFromServer(_ itemToConvert: ServerItem) -> TodoItem {
//    TodoItem(text: String, priority: TodoItem.Priority, deadline: Int?, done: Bool, whenCreated: Int, whenEdited: Int?)
    var priority: TodoItem.Priority {
        switch itemToConvert.importance.rawValue {
        case "important":
            return .major
        case "basic":
            return .common
        case "low":
            return .minor
        default:
            return .common
        }
    }

        var deadline: Int? {
            if let deadline = itemToConvert.deadline {
                return Int(itemToConvert.deadline!)
            } else {
                return nil
            }
        }

        let converted = TodoItem(
            id: itemToConvert.id,
            text: itemToConvert.text,
            priority: priority,
            deadline: deadline,
            done: itemToConvert.done,
            whenCreated: Int(itemToConvert.created_at),
            whenEdited: Int(itemToConvert.changed_at ?? 0))
            
        return converted
    }

 func convertToServer(_ itemToConvert: TodoItem) -> ServerItem {
//     ServerItem(id: String, text: String, importance: ServerItem.serverPriority, done: Bool, color: String, created_at: Int64, changed_at: Int64?, last_updated_by: String)
        var priority: serverPriority {
            switch itemToConvert.priority {
            case .major:
                return .major
            case .common:
                return .common
            case .minor:
                return .minor
            }
        }

        var deadline: Int64? {
            if let deadline = itemToConvert.deadline {
                return Int64(itemToConvert.deadline!)
            } else {
                return nil
            }
        }

        var editedDate: Int64 {
            if let editedDate = itemToConvert.whenEdited {
                return Int64(itemToConvert.whenEdited!)
            } else {
                return 0
            }
        }
     
        let localItem = ServerItem(
            id: itemToConvert.id,
            text: itemToConvert.text,
            importance: priority,
            deadline: deadline,
            done: itemToConvert.done,
            color: "",
            created_at: Int64(itemToConvert.whenCreated),
            changed_at: editedDate,
            last_updated_by: "")

        return localItem
    }
