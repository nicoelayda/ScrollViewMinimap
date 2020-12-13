//
//  Copyright © 2020 Dominic Elayda.
//  Licensed under The MIT License.
//

import UIKit

private let DefaultHighlightAlpha: CGFloat = 0.4
private let DefaultHighlightBorderColor: UIColor = .gray
private let DefaultHighlightBorderWidth: CGFloat = 1
private let DefaultHighlightColor: UIColor = .white

// This is a workaround to disable IBDesignables from Interface Builder when compiled from a
// Swift package, as building source from SPM packages for IB targets doesn't work properly.
#if SWIFT_PACKAGE
open class MinimapBase: UIControl {
    open var highlightAlpha: CGFloat = DefaultHighlightAlpha
    open var highlightBorderColor: UIColor = DefaultHighlightBorderColor
    open var highlightBorderWidth: CGFloat = DefaultHighlightBorderWidth
    open var highlightColor: UIColor = DefaultHighlightColor
}
#else
@IBDesignable
open class MinimapBase: UIControl {
    @IBInspectable open var highlightAlpha: CGFloat = DefaultHighlightAlpha
    @IBInspectable open var highlightBorderColor: UIColor = DefaultHighlightBorderColor
    @IBInspectable open var highlightBorderWidth: CGFloat = DefaultHighlightBorderWidth
    @IBInspectable open var highlightColor: UIColor = DefaultHighlightColor
}
#endif
