import Cocoa
import Foundation

// Value Type Performance



// NSMutableData is value type reference from Foundation

var sampleBytes: [UInt8] = [0x0b, 0xad, 0xf0, 0x0d]
let nsData = NSMutableData(bytes: sampleBytes, length: sampleBytes.count)
// mutablility of data ins't controlled via let/var
//Using let means that the reference type is immutable
nsData.append(sampleBytes, length: sampleBytes.count)
//To do independent copy of data need do this explicitly
let nsOtherData = nsData.mutableCopy() as! NSMutableData
nsData.append(sampleBytes, length: sampleBytes.count)


// Behavior of Values Types
/*
var data = Data(bytes: sampleBytes) // For to use mmmutating data change let to var
var copy = data
data.append(sampleBytes, count: sampleBytes.count)*/

// creating a independent copy

//let copy = data
//data.append(sampleBytes, count: sampleBytes.count)

//values always get the value andf assgn to a another variable or pass func as parameter
// Assign an object to a variable just create a second referebce point to the same obejct

// Implementing Copy-on-Write

// create an wrap
final class Box<A> {
    let unBox: A
    init(_ value: A) {
        unBox = value
    }
}

struct MyData {
    var data = Box(NSMutableData())
    var dataForWriting: NSMutableData {
        mutating get {
            //This function just work with swift objcts - isKnownUniquelyReferenced
            if isKnownUniquelyReferenced(&data) {
                return data.unBox
            }
            print("making a copy")
            data = Box(data.unBox.mutableCopy() as! NSMutableData)
            return data.unBox
        }
    }
    // on-write
    mutating func append(_ bytes: [UInt8]) {
        dataForWriting.append(bytes, length: bytes.count)
    }
}

extension MyData : CustomDebugStringConvertible {
    var debugDescription: String {
        return String(describing: data)
    }
}

var myData = MyData()
var copy = myData
myData.append(sampleBytes)

for _ in 0..<10 {
    myData.append(sampleBytes)
}

(0..<10).reduce(myData) { result, _ in
    var copy = result
    copy.append(sampleBytes)
    return copy
}
