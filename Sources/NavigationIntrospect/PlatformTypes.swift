import SwiftUI
import UIKit

// MARK: - Platform Type Aliases

public typealias PlatformView = UIView
public typealias PlatformViewController = UIViewController

// MARK: - Recursive Sequence Helper

func recursiveSequence<S: Sequence>(_ sequence: S, children: @escaping (S.Element) -> S) -> AnySequence<S.Element> {
    AnySequence {
        var mainIterator = sequence.makeIterator()
        var childIterator: AnyIterator<S.Element>?
        
        return AnyIterator {
            if let child = childIterator?.next() {
                return child
            }
            guard let element = mainIterator.next() else {
                return nil
            }
            childIterator = recursiveSequence(children(element), children: children).makeIterator()
            return element
        }
    }
}
