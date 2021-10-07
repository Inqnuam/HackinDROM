import Foundation
import SwiftUI

struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
    typealias Index = Base.Index
    typealias Element = (index: Index, element: Base.Element)
    let base: Base
    var startIndex: Index { self.base.startIndex }
    var endIndex: Index { self.base.endIndex }
    func index(after i: Index) -> Index {
        self.base.index(after: i)
    }

    func index(before i: Index) -> Index {
        self.base.index(before: i)
    }

    func index(_ i: Index, offsetBy distance: Int) -> Index {
        self.base.index(i, offsetBy: distance)
    }

    subscript(position: Index) -> Element {
        (index: position, element: self.base[position])
    }
}

extension RandomAccessCollection {
    func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}
