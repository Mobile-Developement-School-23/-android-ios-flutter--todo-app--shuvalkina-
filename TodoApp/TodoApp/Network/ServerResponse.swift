
import UIKit
import Foundation

struct ServerResponse: Codable {
    let status: String?
    let list: [ServerItem]
    let revision: Int?

    init (
        status: String? = nil,
        revision: Int? = nil,
        list: [ServerItem]
    ) {
        self.status = status
        self.list = list
        self.revision = revision
    }
}
