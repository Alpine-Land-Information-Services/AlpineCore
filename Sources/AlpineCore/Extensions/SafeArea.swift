//
//  SafeArea.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/18/24.
//

import SwiftUI

public extension UITabBarController {
    var height: CGFloat {
        return self.tabBar.frame.size.height
    }
    
    var width: CGFloat {
        return self.tabBar.frame.size.width
    }
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
    }
}


private extension UIEdgeInsets {
    var swiftUiInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}


public extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}
