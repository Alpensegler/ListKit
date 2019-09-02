var nums = [1, 2, 3, 4]
nums.removeSubrange(3...)


func cast<Value, Result>(some: Value, to: Result.Type) -> Result {
    return some as! Result
}

let result = cast(some: 1, to: Any.self)
let some = cast(some: result, to: Int.self)
