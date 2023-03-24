@testable import ListKit
import XCTest

final class ListCoordinatorContextTests: XCTestCase {

    func testContextWithItemCount() {
        // Given:
        var context = ListCoordinatorContext(coordinator: Count.items(5))

        // Then:
        XCTAssertEqual(context.count, .items(5))
        XCTAssertEqual(context.section.sectioned, false)
        XCTAssertEqual(context.section.removeEmpty, false)
        context.section.sectioned = true
        context.section.removeEmpty = true

        // Then:
        XCTAssertEqual(context.count, .sections(nil, [5], nil))
    }

    func testContextWithSectionsAndSection() {
        // Given:
        var context = ListCoordinatorContext(coordinator: Count.sections(2, [0, 3, 0, 0], 1))

        // Then:
        XCTAssertEqual(context.count, .sections(2, [0, 3, 0, 0], 1))
        XCTAssertEqual(context.section.sectioned, false)
        XCTAssertEqual(context.section.removeEmpty, false)

        context.section.sectioned = true
        context.section.removeEmpty = true

        // Then:
        XCTAssertEqual(context.count, .sections(nil, [2, 3, 1], nil))
    }

}
