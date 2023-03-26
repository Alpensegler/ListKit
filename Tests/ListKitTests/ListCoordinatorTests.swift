@testable import ListKit
import XCTest

extension Count: ListCoordinator {
    public var count: Count { self }
    public func performUpdate(to coordinator: ListKit.ListCoordinator) -> ListKit.BatchUpdates {
        fatalError()
    }
}

struct TestDataSourceCoordinator: DataSourcesCoordinator {
    var contexts: ContiguousArray<ListCoordinatorContext> = []
    var contextsOffsets: ContiguousArray<Offset> = []
    var count: Count = .items(nil)
    var indices: ContiguousArray<(indices: [Int], index: Int?)> = []
    var subselectors: Set<Selector> = []
    var needSetupWithListView: Bool = false
    func performUpdate(to coordinator: ListKit.ListCoordinator) -> ListKit.BatchUpdates {
        fatalError()
    }
}

final class ListCoordinatorTests: XCTestCase {
    func XCTAssertEqualOffsets(_ expression1: ContiguousArray<TestDataSourceCoordinator.Offset>, _ expression2: ContiguousArray<TestDataSourceCoordinator.Offset>, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(expression1.count, expression2.count, "Offsets count mismatch", file: file, line: line)
        for (index, (offset1, offset2)) in zip(expression1, expression2).enumerated() {
            XCTAssertEqual(offset1.sectionOffset, offset2.sectionOffset, "Section offset mismatch at: \(index)", file: file, line: line)
            XCTAssertEqual(offset1.itemOffset, offset2.itemOffset, "Item offset mismatch at: \(index)", file: file, line: line)
        }
    }
    
    func XCTAssertEqualIndices(_ expression1: ContiguousArray<(indices: [Int], index: Int?)>, _ expression2: ContiguousArray<(indices: [Int], index: Int?)>, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(expression1.count, expression2.count, "Indices count mismatch", file: file, line: line)
        for (index, (element1, element2)) in zip(expression1, expression2).enumerated() {
            XCTAssertEqual(element1.indices, element2.indices, "Indices mismatch at: \(index)", file: file, line: line)
            XCTAssertEqual(element1.index, element2.index, "Index mismatch at: \(index)", file: file, line: line)
        }
    }
    
    func testConfigCountCase1() {
        var coordinator = TestDataSourceCoordinator()
        coordinator.contexts = [
            ListCoordinatorContext(coordinator: Count.items(3)),
            ListCoordinatorContext(coordinator: Count.items(2))
        ]
        
        coordinator.configCount()
        XCTAssertEqual(coordinator.count, .items(5))
        XCTAssertEqualOffsets(coordinator.contextsOffsets, [(sectionOffset: 0, itemOffset: 0), (sectionOffset: 0, itemOffset: 3)])
        XCTAssertEqualIndices(coordinator.indices, [([0, 0, 0, 1, 1], nil)])
    }
    
    func testConfigCountCase2() {
        var coordinator = TestDataSourceCoordinator()
        coordinator.contexts = [
            ListCoordinatorContext(coordinator: Count.sections(2, [2], 2)),
            ListCoordinatorContext(coordinator: Count.items(3))
        ]
        
        coordinator.configCount()
        XCTAssertEqual(coordinator.count, .sections(2, [2], 5))
        XCTAssertEqualOffsets(coordinator.contextsOffsets, [(sectionOffset: 0, itemOffset: 0), (sectionOffset: 2, itemOffset: 2)])
        XCTAssertEqualIndices(coordinator.indices, [([0, 0], nil), ([0, 0], 0), ([0, 0, 1, 1, 1], nil)])
    }
    
    func testConfigCountCase3() {
        var coordinator = TestDataSourceCoordinator()
        coordinator.contexts = [
            ListCoordinatorContext(coordinator: Count.items(3)),
            ListCoordinatorContext(coordinator: Count.sections(2, [1], 2))
        ]
        
        coordinator.configCount()
        XCTAssertEqual(coordinator.count, .sections(5, [1], 2))
        XCTAssertEqualOffsets(coordinator.contextsOffsets, [(sectionOffset: 0, itemOffset: 0), (sectionOffset: 0, itemOffset: 3)])
        XCTAssertEqualIndices(coordinator.indices, [([0, 0, 0, 1, 1], nil), ([1], 1), ([1, 1], nil)])
    }
    
    func testConfigCountCase4() {
        var coordinator = TestDataSourceCoordinator()
        coordinator.contexts = [
            ListCoordinatorContext(coordinator: Count.sections(2, [2, 3], 2)),
            ListCoordinatorContext(coordinator: Count.sections(nil, [1], 3))
        ]

        coordinator.configCount()
        XCTAssertEqual(coordinator.count, .sections(2, [2, 3, 2, 1], 3))
        XCTAssertEqualOffsets(coordinator.contextsOffsets, [(sectionOffset: 0, itemOffset: 0), (sectionOffset: 4, itemOffset: 0)])
        XCTAssertEqualIndices(coordinator.indices, [([0, 0], nil), ([0, 0], 0), ([0, 0, 0], 0), ([0, 0], nil), ([1], 1), ([1, 1, 1], nil)])
    }
}
