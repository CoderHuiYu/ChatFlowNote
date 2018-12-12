// Copyright © 2017 Tellus, Inc. All rights reserved.

import UIKit

extension UIView {

    var height: CGFloat {
        return frame.size.height
    }

    var width: CGFloat {
        return frame.size.width
    }
    
    func hitTest(_ point: CGPoint, for views: [UIView], withTapMargin tapMargin: CGFloat, with event: UIEvent?) -> UIView? {
        guard self.point(inside: point, with: event) else { return nil }
        let interactiveViews = views.filter { view in
            let viewAndAncestors = sequence(first: view, next: { $0.superview })
            return viewAndAncestors.allMatch { $0.isUserInteractionEnabled && !$0.isHidden && $0.alpha >= 0.01 }
        }
        let directlyHitViews = interactiveViews.filter { $0.convertBounds(to: self).contains(point) }
        if !directlyHitViews.isEmpty {
            // TODO: Select view on top
            let view = directlyHitViews.first!
            return view.hitTest(convert(point, to: view), with: event) ?? view
        } else if let view = closestView(in: interactiveViews, to: point, withinMaxDistance: tapMargin) {
            return view.hitTest(convert(point, to: view), with: event) ?? view
        } else {
            return nil
        }
    }
    
    func convertBounds(to view: UIView?) -> CGRect {
        return convert(bounds, to: view)
    }

    func setClipToCircle(_ clipToCircle: Bool) {
        if clipToCircle { layer.masksToBounds = true }
        layer.cornerRadius = clipToCircle ? min(frame.width, frame.height)/2 : 0
    }

    convenience init(wrapping view: UIView, with insets: UIEdgeInsets = .zero) {
        self.init()
        addSubview(view, pinningEdges: .all, withInsets: insets)
    }

    /// Fix for an iOS bug: https://github.com/nkukushkin/StackView-Hiding-With-Animation-Bug-Example
    var patched_isHidden: Bool {
        get { return isHidden }
        set { repeat { isHidden = newValue } while isHidden != newValue }
    }

    // MARK: Constraints
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomAnchor
        }
    }

    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.topAnchor
        } else {
            return topAnchor
        }
    }

    @objc func addSubview(_ subview: UIView, pinningEdges edges: UIRectEdge, withInsets insets: UIEdgeInsets = .zero) {
        addSubview(subview)
        subview.pinEdges(edges: edges, to: self, withInsets: insets, useSafeArea: false)
    }

    @objc func addSubview(_ subview: UIView, pinningEdgesToSafeArea edges: UIRectEdge, withInsets insets: UIEdgeInsets = .zero) {
        addSubview(subview)
        subview.pinEdges(edges: edges, to: self, withInsets: insets, useSafeArea: true)
    }

    /// Adds the given subview to the receiver and constrains the given edges to its safe area.
    ///
    /// The constraints will be set up such that the insets merge with any additional margin due to the safe area, if applicable.
    @objc func addSubview(_ subview: UIView, pinningEdgesToSafeArea edges: UIRectEdge, withCollapsingInsets insets: UIEdgeInsets) {
        addSubview(subview)
        subview.pinEdges(edges: edges, to: self, withInsets: insets, useSafeArea: true, collapseInsets: true)
    }

    @discardableResult func pinEdges(edges: UIRectEdge = .all, to view: UIView, withInsets insets: UIEdgeInsets = .zero, useSafeArea: Bool = true, collapseInsets: Bool = false) -> [NSLayoutConstraint] {
        var insets = insets
        translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = []
        if edges.contains(.left) {
            constraints += leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left)
        }
        if edges.contains(.right) {
            constraints += view.rightAnchor.constraint(equalTo: rightAnchor, constant: insets.right)
        }
        if edges.contains(.top) {
            // On pop over view controllers, the nav bar height is always 44 when existent. We shouldn't use the safeTopAnchor in
            // those cases because the pop over view controller could be anywhere in the screen, including above the underlying
            // view controller's safeAreaLayoutGuide topAnchor, in which case it would display an extra gap.
            //
            // TODO: This is not exhaustive/correct.
            // This verification is safe because the only place in the app that we use custom modalPresentationStyle is in ZLPopoverSheetStyle,
            // but it doesn't mean it will cover all other similar cases for other modalPresentationStyles that contain nav bars.
            // TODO: Remove this workaround from such a general utility method.
            let isPresumablyPopoverSheetStyleWithNavigationBar: Bool = {
                if let navController = viewController?.navigationController {
                    return (navController.modalPresentationStyle == .custom)
                }
                return false
            }()
            if isPresumablyPopoverSheetStyleWithNavigationBar {
                constraints += topAnchor.constraint(equalTo: view.topAnchor, constant: useSafeArea ? 44 : 0)
            } else {
                if useSafeArea {
                    if #available(iOS 11, *) {
                        // Do nothing
                    } else {
                        if viewController?.navigationController != nil { insets.top += 64 }
                    }
                }
                if useSafeArea && collapseInsets {
                    constraints += topAnchor.constraint(greaterThanOrEqualTo: view.safeTopAnchor)
                    constraints += topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top).with(priority: .pseudoRequired)
                } else {
                    let viewTopAnchor = useSafeArea ? view.safeTopAnchor : view.topAnchor
                    constraints += topAnchor.constraint(equalTo: viewTopAnchor, constant: insets.top)
                }
            }
        }
        if edges.contains(.bottom) {
            if useSafeArea && collapseInsets {
                constraints += view.safeBottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor)
                constraints += view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom).with(priority: .pseudoRequired)
            } else {
                let viewBottomAnchor = useSafeArea ? view.safeBottomAnchor : view.bottomAnchor
                constraints += viewBottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom)
            }
        }
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    // MARK: Decoration
    func addSeparator(onEdges edges: UIRectEdge, thickness: CGFloat = 1/UIScreen.main.scale) {
        if edges.contains(.left) { addSeparator(on: .minXEdge, thickness: thickness) }
        if edges.contains(.right) { addSeparator(on: .maxXEdge, thickness: thickness) }
        if edges.contains(.top) { addSeparator(on: .minYEdge, thickness: thickness) }
        if edges.contains(.bottom) { addSeparator(on: .maxYEdge, thickness: thickness) }
    }

    private func addSeparator(on edge: CGRectEdge, thickness: CGFloat) {
        let separator = UIView()
        separator.backgroundColor = .zillySeparator()
        switch edge {
        case .minXEdge, .maxXEdge:
            addSubview(separator, pinningEdgesToSafeArea: [ .top, .bottom, (edge == .minXEdge ? .left : .right) ])
            NSLayoutConstraint.activate([ separator.widthAnchor.constraint(equalToConstant: thickness) ])
        case .minYEdge, .maxYEdge:
            addSubview(separator, pinningEdgesToSafeArea: [ .left, .right, (edge == .minYEdge ? .top : .bottom) ])
            NSLayoutConstraint.activate([ separator.heightAnchor.constraint(equalToConstant: thickness) ])
        }
    }

    func addBadge(withOffset offset: CGPoint = .zero) -> UIView {
        let badgeView = UIView()
        badgeView.backgroundColor = .zillyRed()
        badgeView.cornerRadius = 8.0
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badgeView)
        NSLayoutConstraint.activate([
            badgeView.heightAnchor.constraint(equalToConstant: 16),
            badgeView.widthAnchor.constraint(equalToConstant: 16),
            badgeView.centerXAnchor.constraint(equalTo: trailingAnchor, constant: offset.x),
            badgeView.centerYAnchor.constraint(equalTo: topAnchor, constant: offset.y)
            ])
        return badgeView
    }

    func addDottedLine(strokeColor: UIColor, lineWidth: CGFloat) {
        backgroundColor = .clear

        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "DashedTopLine"
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [ 4, 4 ]

        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: frame.width, y: 0))
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }

    /// - Note: In most cases, we should prefer a non-rasterized shadow in combination with a shadow path
    @objc func addRasterizedShadow(ofSize radius: CGFloat, opacity: Float = 0.25, offset: CGSize = CGSize(width: 0, height: 1), color: UIColor = .black) {
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func addShadow(opacity: Float = 0.25, radius: CGFloat, yOffset: CGFloat, color: UIColor = .black) {
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: 0, height: yOffset)
        layer.shadowColor = color.cgColor
    }

    func removeShadow() {
        layer.shadowOpacity = 0
    }

    func getImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        return nil
    }
}
