
import Foundation

protocol FileCacheDelegate {
    func saveData(_ fileType: String, _ fileName: String)
    func loadData(_ fileType: String, _ fileName: String) throws -> Any?
    func addItem (newItem: TodoItem)
    func deleteItem (id: String)
}
protocol URLManagerDelegate {
    func didFail() -> Error
}
protocol EditionDelegate {
    func itemToEdit(item: TodoItem)
    func displayEditItem (item: TodoItem)
}
protocol DismissionDelegate  {
    func add(newItem: TodoItem)
    func save(_ fileType: String, _ fileName: String)
}
