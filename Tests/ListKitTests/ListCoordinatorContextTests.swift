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
    
    func testReconfigCount() {
        let count = Count.items(5)
        var context = ListCoordinatorContext(coordinator: count)

        // Case 1: (sectioned: false, removeEmpty: false)
        context.section = (sectioned: false, removeEmpty: false)
        XCTAssertEqual(context.count, .items(5))

        // Case 2: (sectioned: true, removeEmpty: false)
        context.section = (sectioned: true, removeEmpty: false)
        XCTAssertEqual(context.count, .sections(nil, [5], nil))

        // Case 3: (sectioned: false, removeEmpty: true)
        context.section = (sectioned: false, removeEmpty: true)
        XCTAssertEqual(context.count, .items(5))

        // Case 4: (sectioned: true, removeEmpty: true)
        context.section = (sectioned: true, removeEmpty: true)
        XCTAssertEqual(context.count, .sections(nil, [5], nil))
    }

    func testReconfigCountWithEmptyItems() {
        let count = Count.items(0)
        var context = ListCoordinatorContext(coordinator: count)

        // Case 1: (sectioned: false, removeEmpty: false)
        context.section = (sectioned: false, removeEmpty: false)
        XCTAssertEqual(context.count, .items(0))

        // Case 2: (sectioned: true, removeEmpty: false)
        context.section = (sectioned: true, removeEmpty: false)
        XCTAssertEqual(context.count, .sections(nil, [0], nil))

        // Case 3: (sectioned: false, removeEmpty: true)
        context.section = (sectioned: false, removeEmpty: true)
        XCTAssertEqual(context.count, .items(nil))

        // Case 4: (sectioned: true, removeEmpty: true)
        context.section = (sectioned: true, removeEmpty: true)
        XCTAssertEqual(context.count, .sections(nil, [], nil))
    }
    
    func testReconfigCountWithSections() {
        let count = Count.sections(3, [1, 2, 0], nil)
        var context = ListCoordinatorContext(coordinator: count)

        // Case 1: (sectioned: false, removeEmpty: false)
        context.section = (sectioned: false, removeEmpty: false)
        XCTAssertEqual(context.count, .sections(3, [1, 2, 0], nil))

        // Case 2: (sectioned: true, removeEmpty: false)
        context.section = (sectioned: true, removeEmpty: false)
        XCTAssertEqual(context.count, .sections(nil, [3, 1, 2, 0], nil))

        // Case 3: (sectioned: false, removeEmpty: true)
        context.section = (sectioned: false, removeEmpty: true)
        XCTAssertEqual(context.count, .sections(3, [1, 2], nil))

        // Case 4: (sectioned: true, removeEmpty: true)
        context.section = (sectioned: true, removeEmpty: true)
        XCTAssertEqual(context.count, .sections(nil, [3, 1, 2], nil))
    }

    func testReconfigCountWithSectionsAndEmptyItems() {
        let count = Count.sections(nil, [0, 3, 3, 1], 3)
        var context = ListCoordinatorContext(coordinator: count)

        // Case 1: (sectioned: false, removeEmpty: false)
        context.section = (sectioned: false, removeEmpty: false)
        XCTAssertEqual(context.count, .sections(nil, [0, 3, 3, 1], 3))

        // Case 2: (sectioned: true, removeEmpty: false)
        context.section = (sectioned: true, removeEmpty: false)
        XCTAssertEqual(context.count, .sections(nil, [0, 3, 3, 1, 3], nil))

        // Case 3: (sectioned: false, removeEmpty: true)
        context.section = (sectioned: false, removeEmpty: true)
        XCTAssertEqual(context.count, .sections(nil, [3, 3, 1], 3))

        // Case 4: (sectioned: true, removeEmpty: true)
        context.section = (sectioned: true, removeEmpty: true)
        XCTAssertEqual(context.count, .sections(nil, [3, 3, 1, 3], nil))
    }

}
