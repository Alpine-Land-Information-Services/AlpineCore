//
//  File.swift
//  
//
//  Created by Jenya Lebid on 5/31/23.
//

import CoreData

public class DeallocationObserver {
    
    var onDeinit: (() -> Void)?

    deinit {
        onDeinit?()
    }
}

public extension NSManagedObject {
    
    struct AssociatedKeys {
        static var deallocationObserver = "deallocationObserver"
    }
}

public extension CDObject {
    
    private var deallocationObserver: DeallocationObserver? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.deallocationObserver) as? DeallocationObserver
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.deallocationObserver,
                newValue as DeallocationObserver?,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    func observeDeallocation() {
        let observer = DeallocationObserver()
        let entityName = self.entityName
        let id = self.guid
        observer.onDeinit = {
            print("\(entityName): \(id.uuidString) is being deallocated.")
        }
        self.deallocationObserver = observer
    }
}
