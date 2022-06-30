//
//  PublishedProperties_CombineLike.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 17.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import Foundation
// See https://www.swiftbysundell.com/articles/published-properties-in-swift/


@propertyWrapper
struct Published<Value> {
    var projectedValue: Published { self }
    var wrappedValue: Value { didSet { valueDidChange() } }

    private var observations = MutableReference(
        value: List<(Value) -> Void>()
    )

    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

private extension Published {
    func valueDidChange() {
        for closure in observations.value {
            closure(wrappedValue)
        }
    }
}

class Cancellable {
    private var closure: (() -> Void)?

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    deinit {
        cancel()
    }

    func cancel() {
        closure?()
        closure = nil
    }
}


extension Published {
    func observe(with closure: @escaping (Value) -> Void) -> Cancellable {
        // To further mimmic Combine's behaviors, we'll call
        // each observation closure as soon as it's attached to
        // our property:
        closure(wrappedValue)

        let node = observations.value.append(closure)

        return Cancellable { [weak observations] in
            observations?.value.remove(node)
        }
    }
}


// *** Mutable reference,
// see https://www.swiftbysundell.com/articles/combining-value-and-reference-types-in-swift/

class Reference<Value> {
    fileprivate(set) var value: Value

    init(value: Value) {
        self.value = value
    }
}

class MutableReference<Value>: Reference<Value> {
    func update(with value: Value) {
        self.value = value
    }
}


// *** List
// see https://www.swiftbysundell.com/articles/picking-the-right-data-structure-in-swift/
struct List<Value> {
    private(set) var firstNode: Node?
    private(set) var lastNode: Node?
}

extension List {
    class Node {
        var value: Value
        fileprivate(set) weak var previous: Node?
        fileprivate(set) var next: Node?

        init(value: Value) {
            self.value = value
        }
    }
}

extension List {
    @discardableResult
    mutating func append(_ value: Value) -> Node {
        let node = Node(value: value)
        node.previous = lastNode

        lastNode?.next = node
        lastNode = node

        if firstNode == nil {
            firstNode = node
        }

        return node
    }
}


extension List {
    mutating func remove(_ node: Node) {
        node.previous?.next = node.next
        node.next?.previous = node.previous

        // Using "triple-equals" we can compare two class
        // instances by identity, rather than by value:
        if firstNode === node {
            firstNode = node.next
        }

        if lastNode === node {
            lastNode = node.previous
        }

        // Completely disconnect the node by removing its
        // sibling references:
        node.next = nil
        node.previous = nil
    }
}


extension List: Sequence {
    func makeIterator() -> AnyIterator<Value> {
        var node = firstNode

        return AnyIterator {
            // Iterate through all of our nodes by continuously
            // moving to the next one and extract its value:
            let value = node?.value
            node = node?.next
            return value
        }
    }
}
