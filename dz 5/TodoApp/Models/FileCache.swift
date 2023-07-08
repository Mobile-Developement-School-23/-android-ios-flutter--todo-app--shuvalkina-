import Foundation

final class FileCache: FileCacheDelegate {

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
        print(todoItems.count, "кол-во айтемов")

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
