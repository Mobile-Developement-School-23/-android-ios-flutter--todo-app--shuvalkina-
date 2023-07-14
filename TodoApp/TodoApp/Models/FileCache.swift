import Foundation
import UIKit
import CoreData

final class FileCache: FileCacheDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemsCD = [Item]()
    private(set) var todoItems = [TodoItem]()
    func deleteCache() {
        todoItems = []
    }
    func addItem (newItem: TodoItem) {
        // проверка списка заданий на дубликат по айди и последующая перезапить содержимого
        if let row = self.todoItems.firstIndex(where: {$0.id == newItem.id}) {
            todoItems[row] = newItem
            return
        }
        todoItems.append(newItem)
    }
    func deleteItem (id: String) {
        if let row = self.todoItems.firstIndex(where: {$0.id == id}) {
            todoItems.remove(at: row)
        }
    }
    func saveData(_ fileType: String, _ fileName: String) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            var fileURL = url.appendingPathComponent(fileName)
            fileURL = fileURL.appendingPathExtension(fileType)
            // проверка файла на существование и последующее удаление
            if fileManager.fileExists(atPath: fileURL.path) {
                do {
                    try fileManager.removeItem(atPath: fileURL.path)
                } catch { print("ошибка удаления существующего файла")}
            }
            // сохранение коллекции заданий в файл заданном расширении
            if fileType == "json" {
                if let data = try? JSONSerialization.data(withJSONObject:
                                                            todoItems.map(\.json),
                                                          options:
                                                            [.prettyPrinted]) {
                    do {
                        try data.write(to: fileURL)
                        print(fileURL)
                    } catch {
                        print("ошибка в записи json файл")
                    }
                }
            } else {
                var csvString = "\("id"),\("text"),\("priority"),\("deadline"),\("done"),\("whenCreated"),\("whenEdited")\n\n"
                for todo in todoItems {
                    csvString += todo.csv
                    do {
                        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
                    } catch {
                        print("ошибка в записи csv файл")
                    }
                }
            }
        }
    }
    func loadData(_ fileType: String, _ fileName: String) throws -> Any? {
        let fmr = FileManager.default
        let urls = fmr.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            var fileURL = url.appendingPathComponent(fileName)
            fileURL = fileURL.appendingPathExtension(fileType)
            print(fileURL)
            if fileType == "json" {
                if let data = try? Data(contentsOf: fileURL) {
                    do {
                        var todos: [TodoItem] = []
                        let loadedData = try JSONSerialization.jsonObject(
                            with: data,
                            options: [.mutableContainers, .mutableLeaves])
                        // swiftlint:disable:next force_cast
                        for todo in (loadedData as! [Any]) {
                            if let item = TodoItem.parseJSON(json: todo) {
                                todos.append(item)
                            }
                        }
                        todoItems = todos
                        return todoItems
                    } catch {
                        print("ошибка загрузки из json файла")
                    }
                }
            } else {
                    do {
                        let loadedData = try String(contentsOfFile: fileURL.path, encoding: String.Encoding.utf8)
                        todoItems.append(TodoItem.parse(csv: loadedData)!)
                        return todoItems
                    } catch {
                        print("ошибка загрузки из csv файла")
                    }
                }
            }
        return nil
        }
    }
extension FileCache {
    func saveItemsToCoreData () {
            do {
                try context.save()
            } catch {
                print(" Ошибка сохранения Core Data \(error)")
            }
        }
    func loadItemsFromCD() throws -> Any? {
        if let coreDataItems = try? context.fetch(Item.fetchRequest()) {
            itemsCD = coreDataItems
            var todos: [TodoItem] = []
            for todo in itemsCD {
                if let item = TodoItem.parseCD(coreData: todo) {
                    todos.append(item)
                }
            }
        }
        return itemsCD

    }

    // метод проверяет на дубликат и вставляет новый айтем в core data
    func insertItemToCD(iremToInsert: TodoItem) {
        let item: Item!
//        let newItem = iremToInsert.CoreData
        if let row = self.itemsCD.firstIndex(where: {$0.id == iremToInsert.id}) {
            itemsCD[row].setValue(iremToInsert.id, forKey: "id")
            itemsCD[row].setValue(iremToInsert.text, forKey: "text")
            itemsCD[row].setValue(iremToInsert.deadline, forKey: "deadline")
            itemsCD[row].setValue(iremToInsert.done, forKey: "done")
            itemsCD[row].setValue(iremToInsert.priority.rawValue, forKey: "priority")
            itemsCD[row].setValue(iremToInsert.whenEdited, forKey: "whenEdited")
            itemsCD[row].setValue(iremToInsert.whenCreated, forKey: "whenCreated")
        } else {
            let newItem = Item(context: context)
            newItem.setValue(iremToInsert.id, forKey: "id")
            newItem.setValue(iremToInsert.text, forKey: "text")
            newItem.setValue(iremToInsert.deadline, forKey: "deadline")
            newItem.setValue(iremToInsert.done, forKey: "done")
            newItem.setValue(iremToInsert.priority.rawValue, forKey: "priority")
            newItem.setValue(iremToInsert.whenEdited, forKey: "whenEdited")
            newItem.setValue(iremToInsert.whenCreated, forKey: "whenCreated")
            print(newItem.deadline)
            itemsCD.append(newItem)
            context.insert(newItem)
            
        }
        let fetchItem: NSFetchRequest<Item> = Item.fetchRequest()
        fetchItem.predicate = NSPredicate(format: "id == %@", iremToInsert.id as String)
         let results = try? context.fetch(fetchItem)

         if results?.count != 0 {
            // айтем уже добавлен выше просто оставила место, если понабодится
         } else {
             // обновление айтема если такой уже есть
             item = results?.first
             item.text = iremToInsert.text
             if iremToInsert.deadline != nil {
                 item.deadline = Int32(iremToInsert.deadline!)
             }
             item.done = iremToInsert.done
             item.priority = iremToInsert.priority.rawValue
             if iremToInsert.whenEdited != nil {
                 item.whenEdited = Int32(iremToInsert.whenEdited!)
             }
             item.whenCreated = Int32(iremToInsert.whenCreated)
         }
        do {
            try context.save()
        } catch {
            print(" Ошибка сохранения Core Data в методе insert \(error)")
        }
    }
    func deleteItemFromCD(idToDelete: String) {
        itemsCD.forEach { item in
            if item.id == idToDelete{
                context.delete(item)
            }
        }
        if let row = self.itemsCD.firstIndex(where: {$0.id == idToDelete}) {
            context.delete(itemsCD[row])
            itemsCD.remove(at: row)
        }
        do {
            try context.save()
        } catch {
            print(" Ошибка сохранения Core Data в методе insert \(error)")
        }
        
    }
    // не используется потому что включен в методе insert
    func updateItemInCD(itemToUpdate: TodoItem) {
        let item: Item!
        let fetchItem: NSFetchRequest<Item> = Item.fetchRequest()
        fetchItem.predicate = NSPredicate(format: "id", itemToUpdate.id as String)
        let results = try? context.fetch(fetchItem)
        item = results?.first
    item.text = itemToUpdate.text
    if itemToUpdate.deadline != nil {
        item.deadline = Int32(itemToUpdate.deadline!)
    }
    item.done = itemToUpdate.done
    item.priority = itemToUpdate.priority.rawValue
    if itemToUpdate.whenEdited != nil {
        item.whenEdited = Int32(itemToUpdate.whenEdited!)
    }
    item.whenCreated = Int32(itemToUpdate.whenCreated)
            do {
                try context.save()
            } catch {
                print(" Ошибка изменения айтема Core Data в методе update \(error)")
            }
        }
    }

    
    extension TodoItem {
        var CoreData: NSManagedObject {
            let item = Item()
            item.id = id
            item.text = text
            item.done = done
            item.whenCreated = Int32(whenCreated)
            if priority != .common {
                item.priority = priority.rawValue
            }
            if let whenEdited {
                item.whenEdited = Int32(whenEdited)
            }
            if let deadline {
                item.deadline = Int32(deadline)
            }
            return item
        }
        
        static func parseCD(coreData: Any) -> TodoItem? {
            guard let coreData = coreData as? Item
            else {
                print("ошибка даункаста Core Data ")
                return nil
            }
            var deadlineCD: Int?
            let id = coreData.id
            let text = coreData.text
            let done = coreData.done
            let whenCreated = Int(coreData.whenCreated)
            let whenEdited = Int(coreData.whenEdited)
            var priority = Priority.common
            if !(coreData.priority == nil) {
                let priorityString = coreData.priority
                priority = Priority(rawValue: priorityString!)!
            }
            if coreData.deadline != 0 {
                            deadlineCD = Int(coreData.deadline)
                        }
            let item = TodoItem(
                id: id!,
                text: text!,
                priority: priority,
                deadline: deadlineCD,
                done: done,
                whenCreated: whenCreated,
                whenEdited: whenEdited )
            

            return item
        }
    }

