// swiftlint:disable all
import XCTest

@testable import TodoApp

final class TodoTests: XCTestCase {
    func testExample() throws {
//        let item = TodoItem(id: "1", text: "2", priority: .common, deadline: nil, done: false, whenCreated: 123134421123, whenEdited: nil)
//        let item2 =  TodoItem.parseJSON(json: json.data(using: .utf8))!
//        XCTAssert(item.id == item2.id)
    }
}

private let json = """
{
  "whenCreated" : 708517647,
  "id" : "35B7A04F-5364-49A4-80E3-5710E4F8BF76",
  "text" : "закончить ДЗ 1",
  "done" : false,
  "priority" : "major"
}
"""
