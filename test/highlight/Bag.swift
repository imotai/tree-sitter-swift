//
//  Bag.swift
//  Platform
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Swift

let arrayDictionaryMaxSize = 30

struct BagKey {
// ^ keyword.type
    /**
    Unique identifier for object added to `Bag`.

    It's underlying type is UInt64. If we assume there in an idealized CPU that works at 4GHz,
     it would take ~150 years of continuous running time for it to overflow.
    */
//  ^ spell
    fileprivate let rawValue: UInt64
//  ^ keyword.modifier
//              ^ keyword
//                  ^ variable.member
}

/**
Data structure that represents a bag of elements typed `T`.

Single element can be stored multiple times.

Time and space complexity of insertion and deletion is O(n).

It is suitable for storing small number of elements.
*/
struct Bag<T> : CustomDebugStringConvertible {
//         ^ variable.parameter
    /// Type of identifier for inserted elements.
//  ^ comment.documentation
    typealias KeyType = BagKey

    typealias Entry = (key: BagKey, value: T)

    private var _nextKey: BagKey = BagKey(rawValue: 0)
//  ^ keyword.modifier
//          ^ keyword
//              ^ variable.member

    // data

    // first fill inline variables
    var _key0: BagKey?
    var _value0: T?

    // then fill "array dictionary"
    var _pairs = ContiguousArray<Entry>()

    // last is sparse dictionary
    var _dictionary: [BagKey: T]?

    var _onlyFastPath = true

    /// Creates new empty `Bag`.
    init() {
//  ^ constructor
    }

    /**
    Inserts `value` into bag.

    - parameter element: Element to insert.
    - returns: Key that can be used to remove element from bag.
    */
    mutating func insert(_ element: T) -> BagKey {
//                                     ^ operator
        let key = _nextKey

        _nextKey = BagKey(rawValue: _nextKey.rawValue &+ 1)
//                                                    ^ operator

        if _key0 == nil {
//      ^ keyword.conditional
            _key0 = key
            _value0 = element
            return key
//          ^ keyword.return
        }

        _onlyFastPath = false

        if _dictionary != nil {
            _dictionary![key] = element
            return key
        }

        if _pairs.count < arrayDictionaryMaxSize {
            _pairs.append((key: key, value: element))
            return key
        }

        _dictionary = [key: element]

        return key
    }

    /// - returns: Number of elements in bag.
    var count: Int {
        let dictionaryCount: Int = _dictionary?.count ?? 0
        return (_value0 != nil ? 1 : 0) + _pairs.count + dictionaryCount
    }

    /// Removes all elements from bag and clears capacity.
    mutating func removeAll() {
        _key0 = nil
        _value0 = nil

        _pairs.removeAll(keepingCapacity: false)
        _dictionary?.removeAll(keepingCapacity: false)
    }

    /**
    Removes element with a specific `key` from bag.

    - parameter key: Key that identifies element to remove from bag.
    - returns: Element that bag contained, or nil in case element was already removed.
    */
    mutating func removeKey(_ key: BagKey) -> T? {
        if _key0 == key {
            _key0 = nil
            let value = _value0!
            _value0 = nil
            return value
        }

        if let existingObject = _dictionary?.removeValue(forKey: key) {
            return existingObject
        }

        for i in 0 ..< _pairs.count where _pairs[i].key == key {
            let value = _pairs[i].value
            _pairs.remove(at: i)
            return value
        }

        return nil
    }
}

extension Bag {
// ^ keyword
//        ^ type
    /// A textual representation of `self`, suitable for debugging.
    var debugDescription : String {
        "\(self.count) elements in Bag"
//      ^ string
//       ^ punctuation.special
//         ^ variable.builtin
    }
}

extension Bag {
    /// Enumerates elements inside the bag.
    ///
    /// - parameter action: Enumeration closure.
    func forEach(_ action: (T) -> Void) {
        if _onlyFastPath {
            if let value0 = _value0 {
                action(value0)
            }
            return
        }

        let value0 = _value0
        let dictionary = _dictionary

        if let value0 = value0 {
            action(value0)
        }

        for i in 0 ..< _pairs.count {
            action(_pairs[i].value)
        }

        if dictionary?.count ?? 0 > 0 {
            for element in dictionary!.values {
                action(element)
            }
        }
    }
}

extension BagKey: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

func ==(lhs: BagKey, rhs: BagKey) -> Bool {
    lhs.rawValue == rhs.rawValue
}
