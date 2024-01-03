//
//  Differing.swift
//  Difference
//
//  Created by Zeu on 2019/3/17.
//

// swiftlint:disable all

func diff<Element>(
    from old: ContiguousArray<Element>, to new: ContiguousArray<Element>,
    getIdentifier: ((Element) -> AnyHashable)? = nil,
    using areEquivalent: ((Element, Element) -> Bool)
) -> (inserts: [Int], removes: [Int], moved: [Mapping<Int>]?) {
    if let getIdentifier = getIdentifier {
        return _heckel(from: old, to: new, getIdentifier: getIdentifier, using: areEquivalent)
    } else {
        return _myers(from: old, to: new, using: areEquivalent)
    }
}

/// paste from https://github.com/zzzzeu/ListDiff/blob/main/Sources/ListDiff/ListDiff.swift

fileprivate struct Stack<Element> {
    var items = [Element]()
    var isEmpty: Bool {
        return self.items.isEmpty
    }
    mutating func push(_ item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
}

fileprivate class Entry {
    // 数据出现在旧数组中的次数
    var oldCounter: Int = 0
    // 数据出现在新数组中的次数
    var newCounter: Int = 0
    // 数据在旧数组中的索引，在新数组中则压入空值
    var oldIndexes = Stack<(Int, Int)?>()
    // 标记需要更新的数据
    var updated: Bool = false
    // 数据是否出现在新旧数组两边
    var occurOnBothSides: Bool {
        return newCounter > 0 && oldCounter > 0
    }

    func push(new index: (Int, Int)?) {
        newCounter += 1
        oldIndexes.push(index)
    }

    func push(old index: (Int, Int)?) {
        oldCounter += 1
        oldIndexes.push(index)
    }
}

fileprivate struct Record {
    // 每个新旧数据的 index 都对应一个 record
    let entry: Entry
    // 记录新数据在旧数组中的位置或旧数据在新数组中的位置，不存在则默认为空值
    var index: Int?
    init(_ entry: Entry) {
        self.entry = entry
    }
}

func _heckel<Element>(
    from old: ContiguousArray<Element>, to new: ContiguousArray<Element>,
    getIdentifier: (Element) -> AnyHashable,
    using cmp: (Element, Element) -> Bool
) -> (inserts: [Int], removes: [Int], moved: [Mapping<Int>]?) {
    var deleted = [Int]()
    var inserted = [Int]()
    var updated = Set<Int>()
    var moved = [Mapping<Int>]()
    var oldMap = [AnyHashable: Int]()
    var newMap = [AnyHashable: Int]()

    // 数据 id 作为 key，entry 作为 value
    var table = [AnyHashable: Entry](minimumCapacity: max(old.count, new.count))

    // 第一次遍历
    // 为新数组中的每个元素创建一个 entry
    // 元素每次出现时 newCounter 计数增加，oldIndexes 栈中 push 一个空值
    var newRecords = new.map { (newRecord) -> Record in
        let key = getIdentifier(newRecord)
        if let entry = table[key] {
            entry.push(new: nil)
            return Record(entry)
        } else { //第一次出现的元素
            let entry = Entry()
            entry.push(new: nil)
            table[key] = entry
            return Record(entry)
        }
    }

    // 第二次遍历
    // 栈后进先出，倒序遍历旧数组，为旧数组中的每个元素创建一个 entry
    // 元素每次出现时 oldCounter 计数增加，oldIndexes 栈中 push 元素在旧数组中的 index
    var intIndex = old.count - 1
    var oldRecords = old.indices.reversed().map { i -> Record in
        defer {
            intIndex -= 1
        }
        let oldRecord = old[i]
        let key = getIdentifier(oldRecord)
        if let entry = table[key] {
            entry.push(old: (i, intIndex))
            return Record(entry)
        } else { //第一次出现的元素
            let entry = Entry()
            entry.push(old: (i, intIndex))
            table[key] = entry
            return Record(entry)
        }
    }

    // 第三次遍历
    // 处理在两边数组中都有出现的元素
    var index = new.startIndex
    for i in newRecords.indices {
        defer {
            index = new.index(after: index)
        }
        let newRecord = newRecords[i]
        if !newRecord.entry.occurOnBothSides {
            continue
        }
        let entry = newRecord.entry
        //取栈顶的index，如果为空值则表示该元素需要insert
        guard let (oldIndex, intIndex) = entry.oldIndexes.pop() else {
            continue
        }
        // 标记元素是否需要update
        if cmp(new[index], old[oldIndex]) {
            entry.updated = true
        }
        // 将新数据的 index 赋值给 oldRecord.index，旧数据的 index 赋值给 newRecord.index
        newRecords[i].index = intIndex
        oldRecords[intIndex].index = i
    }

    // 第四遍遍历
    // 计算删除项的偏移量，记录该位置前的删除操作次数
    // 检查需要删除的元素，index 加入 result
    var runningOffset = 0
    index = old.startIndex
    let deleteOffsets = oldRecords.enumerated().map { (i, oldRecord) -> Int in
        let deleteOffset = runningOffset
        // 如果oldRecord中index为nil，则需要删除，offset + 1
        if oldRecord.index == nil {
            deleted.append(i)
            runningOffset += 1
        }
        oldMap[getIdentifier(old[index])] = i
        index = old.index(after: index)
        return deleteOffset
    }

    // 第五遍遍历
    // 重置插入项的偏移量，计算移动位置
    runningOffset = 0
    index = new.startIndex
    newRecords.enumerated().forEach { (i, newRecord) in
        let insertOffset = runningOffset
        //newRecord.index有值则表示该元素需要update/move
        if let oldIndex = newRecord.index {
            //检查entry的updated标记
            if newRecord.entry.updated {
                updated.insert(oldIndex)
            }

            // 计算偏移量，如果相等则不需要move
            let deleteOffset = deleteOffsets[oldIndex]
            if (oldIndex - deleteOffset + insertOffset) != i {
                moved.append((oldIndex, i))
            }
        } else {
            // 需要insert的新元素，offset + 1
            inserted.append(i)
            runningOffset += 1
        }
        newMap[getIdentifier(new[index])] = i
        index = new.index(after: index)
    }

    // 将 move + update 转换为 delete + insert
    for (index, move) in moved.enumerated().reversed() {
        if let _ = updated.remove(move.source) {
            moved.remove(at: index)
            deleted.append(move.source)
            inserted.append(move.source)
        }
    }

    // 将 update 转换为 delete + insert
    for (key, oldIndex) in oldMap {
        if updated.contains(oldIndex), let newIndex = newMap[key] {
            deleted.append(oldIndex)
            inserted.append(newIndex)
        }
    }

    return (inserted, deleted, moved)
}

// _V is a rudimentary type made to represent the rows of the triangular matrix type used by the Myer's algorithm
//
// This type is basically an array that only supports indexes in the set `stride(from: -d, through: d, by: 2)` where `d` is the depth of this row in the matrix
// `d` is always known at allocation-time, and is used to preallocate the structure.
fileprivate struct _V {
    
    private var a: [Int]
    
    // The way negative indexes are implemented is by interleaving them in the empty slots between the valid positive indexes
    @inline(__always) private static func transform(_ index: Int) -> Int {
        // -3, -1, 1, 3 -> 3, 1, 0, 2 -> 0...3
        // -2, 0, 2 -> 2, 0, 1 -> 0...2
        return (index <= 0 ? -index : index &- 1)
    }
    
    init(maxIndex largest: Int) {
        a = [Int](repeating: 0, count: largest + 1)
    }
    
    subscript(index: Int) -> Int {
        get {
            return a[_V.transform(index)]
        }
        set(newValue) {
            a[_V.transform(index)] = newValue
        }
    }
}

func _myers<Element>(
    from old: ContiguousArray<Element>, to new: ContiguousArray<Element>,
    using cmp: (Element, Element) -> Bool
) -> (inserts: [Int], removes: [Int], moved: [Mapping<Int>]?) {
    // Core implementation of the algorithm described at http://www.xmailserver.org/diff2.pdf
    // Variable names match those used in the paper as closely as possible
    func _descent(from a: UnsafeBufferPointer<Element>, to b: UnsafeBufferPointer<Element>) -> [_V] {
        let n = a.count
        let m = b.count
        let max = n + m
        
        var result = [_V]()
        var v = _V(maxIndex: 1)
        v[1] = 0
        
        var x = 0
        var y = 0
    iterator: for d in 0...max {
        let prev_v = v
        result.append(v)
        v = _V(maxIndex: d)

        // The code in this loop is _very_ hot—the loop bounds increases in terms
        // of the iterator of the outer loop!
        for k in stride(from: -d, through: d, by: 2) {
            if k == -d {
                x = prev_v[k &+ 1]
            } else {
                let km = prev_v[k &- 1]

                if k != d {
                    let kp = prev_v[k &+ 1]
                    if km < kp {
                        x = kp
                    } else {
                        x = km &+ 1
                    }
                } else {
                    x = km &+ 1
                }
            }
            y = x &- k

            while x < n && y < m {
                if !cmp(a[x], b[y]) {
                    break;
                }
                x &+= 1
                y &+= 1
            }

            v[k] = x

            if x >= n && y >= m {
                break iterator
            }
        }
        if x >= n && y >= m {
            break
        }
    }
        
        return result
    }
    
    // Backtrack through the trace generated by the Myers descent to produce the changes that make up the diff
    func _formChanges(
        from a: UnsafeBufferPointer<Element>,
        to b: UnsafeBufferPointer<Element>,
        using trace: [_V]
    ) -> (inserts: [Int], removes: [Int], moved: [Mapping<Int>]?) {
        var inserts = [Int]()
        var removes = [Int]()
        inserts.reserveCapacity(trace.count)
        removes.reserveCapacity(trace.count)
        
        var x = a.count
        var y = b.count
        for d in stride(from: trace.count &- 1, to: 0, by: -1) {
            let v = trace[d]
            let k = x &- y
            let prev_k = (k == -d || (k != d && v[k &- 1] < v[k &+ 1])) ? k &+ 1 : k &- 1
            let prev_x = v[prev_k]
            let prev_y = prev_x &- prev_k
            
            while x > prev_x && y > prev_y {
                // No change at this position.
                x &-= 1
                y &-= 1
            }
            
            if y != prev_y {
                inserts.append(prev_y)
            } else {
                removes.append(prev_x)
            }
            
            x = prev_x
            y = prev_y
        }
        
        return (inserts, removes, nil)
    }

    return old.withUnsafeBufferPointer { a in
        return new.withUnsafeBufferPointer { b in
            return _formChanges(from: a, to: b, using: _descent(from: a, to: b))
        }
    }
}
