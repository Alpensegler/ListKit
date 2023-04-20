@testable import ListKit
import XCTest

final class ListCoordinatorContextTests: XCTestCase {

    func testContextWithItemCount() {
        var context = ListCoordinatorContext(coordinator: Count.items(5))
        context.configSectioned(true)
        XCTAssertEqual(context.count, .sectioned([5], style: .remove(mapping: nil)))
    }

    func testReconfigCountWithEmptyItems() {
        var context = ListCoordinatorContext(coordinator: Count.items(0))
        context.configSectioned()
        XCTAssertEqual(context.count, .sectioned([0], style: .keep))
        context.configSectioned(true)
        XCTAssertEqual(context.count, .sectioned([], style: .remove(mapping: nil)))
    }

    func testContextWithSectionsAndSection() {
        var context = ListCoordinatorContext(coordinator: Count.sections(2, [0, 3, 0, 0], 1))
        context.configSectioned()
        XCTAssertEqual(context.count, .sectioned([2, 0, 3, 0, 0, 1], style: .keep))
        context.configSectioned(true)
        XCTAssertEqual(context.count, .sectioned([2, 3, 1], style: .remove(mapping: [0, 2, 5])))
    }
    
    func testReconfigCountWithSections() {
        var context = ListCoordinatorContext(coordinator: Count.sections(3, [1, 2, 0], nil))
        context.configSectioned()
        XCTAssertEqual(context.count, .sectioned([3, 1, 2, 0], style: .keep))
        context.configSectioned(true)
        XCTAssertEqual(context.count, .sectioned([3, 1, 2], style: .remove(mapping: [0, 1, 2])))
    }

    func testReconfigCountWithSectionsAndEmptyItems() {
        var context = ListCoordinatorContext(coordinator: Count.sections(nil, [0, 3, 3, 1], 3))
        context.configSectioned()
        XCTAssertEqual(context.count, .sectioned([0, 3, 3, 1, 3], style: .keep))
        context.configSectioned(true)
        XCTAssertEqual(context.count, .sectioned([3, 3, 1, 3], style: .remove(mapping: [1, 2, 3, 4])))
    }
}
