//
//  KagomeTransitioningDelegate.swift
//  Kagome
//
//  Created by Philip Kluz on 2018-03-11.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import UIKit

extension UIDevice {
    
    fileprivate static var isIPhoneX: Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                return true
            default:
                return false
            }
        }
        
        return false
    }
}

public final class KagomeTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    // MARK: - KagomeTransitioningDelegate
    
    public var shouldCoverSourceController: Bool = false
    public var cornerRadius: CGFloat = 8.0
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return KagomeTransitionController(isPresenting: true,
                                          shouldCover: shouldCoverSourceController,
                                          cornerRadius: cornerRadius)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var radius: CGFloat = 0.0
        if dismissed.presentingViewController != nil && dismissed.presentingViewController?.transitioningDelegate is KagomeTransitioningDelegate {
           radius = self.cornerRadius
        }
        return KagomeTransitionController(isPresenting: false,
                                          shouldCover: shouldCoverSourceController,
                                          cornerRadius: radius)
    }
}

public final class KagomeTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - KagomeTransitionController
    
    private let isPresenting: Bool
    private let shouldCover: Bool
    private let cornerRadius: CGFloat
    
    public init(isPresenting presenting: Bool,
                shouldCover: Bool,
                cornerRadius: CGFloat = 8.0) {
        self.isPresenting = presenting
        self.shouldCover = shouldCover
        self.cornerRadius = cornerRadius
        super.init()
    }
    
    private func rearViewTranslation(isFirst: Bool) -> CGFloat {
        if isFirst {
            if UIDevice.isIPhoneX {
                return 4.0
            }
            return -8.0
        } else {
            if UIDevice.isIPhoneX {
                return -30.0
            }
            return -24.0
        }
    }
    
    private var modalTopDistance: CGFloat {
        if UIDevice.isIPhoneX {
            return shouldCover ? 0.0 : 50.0
        }
        
        return shouldCover ? 0.0 : 30.0
    }
    
    private var scaleFactor: CGFloat = 0.95
    private var sourceOldCornerRadius: CGFloat = 0.0
    private var targetOldCornerRadius: CGFloat = 0.0
    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.0
        view.tag = KagomeTransitionController.dimViewTag
        return view
    }()
    
    private static let dimViewTag: Int = 33295761735
    private static let snapshotViewTag: Int = 52186628380
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        
        guard let fromController = transitionContext.viewController(forKey: .from),
              let snapshottedFromView = transitionContext.viewController(forKey: .from)?.view.snapshotView(afterScreenUpdates: false),
              let toController = transitionContext.viewController(forKey: .to) else { return }
        
        if isPresenting {
            containerView.addSubview(snapshottedFromView)
            containerView.addSubview(dimView)
            containerView.addSubview(toController.view)
            
            snapshottedFromView.tag = KagomeTransitionController.snapshotViewTag
            snapshottedFromView.frame = fromController.view.frame
            dimView.frame = containerView.bounds
            
            toController.view.frame = CGRect(x: 0.0,
                                             y: containerView.bounds.height,
                                             width: containerView.bounds.width,
                                             height: containerView.bounds.height)
            sourceOldCornerRadius = fromController.view.layer.cornerRadius
            targetOldCornerRadius = toController.view.layer.cornerRadius
            
            UIView.animate(withDuration: duration, animations: {
                fromController.view.layer.cornerRadius = self.cornerRadius
                fromController.view.layer.masksToBounds = true
                snapshottedFromView.layer.cornerRadius = self.cornerRadius
                snapshottedFromView.layer.masksToBounds = true
                toController.view.layer.cornerRadius = self.cornerRadius
                toController.view.layer.masksToBounds = true
                
                self.dimView.alpha = 0.6
                
                let fromTransfrom: CGAffineTransform = {
                    if fromController.view.frame == containerView.bounds {
                        let scale = CGAffineTransform(scaleX: self.scaleFactor * 0.97, y: self.scaleFactor * 0.97)
                        let translate = CGAffineTransform(translationX: 0.0, y: self.rearViewTranslation(isFirst: true))
                        return scale.concatenating(translate)
                    } else {
                        let scale = CGAffineTransform(scaleX: self.scaleFactor, y: self.scaleFactor)
                        let translate = CGAffineTransform(translationX: 0.0, y: self.rearViewTranslation(isFirst: false))
                        return scale.concatenating(translate)
                    }
                }()
                
                fromController.view.transform = fromTransfrom
                snapshottedFromView.transform = fromTransfrom
                
                if self.shouldCover {
                    toController.view.frame = transitionContext.finalFrame(for: toController)
                } else {
                    toController.view.frame = transitionContext.finalFrame(for: toController).offsetBy(dx: 0.0, dy: self.modalTopDistance)
                }
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        } else {
            let dimView = containerView.subviews.first(where: { $0.tag == KagomeTransitionController.dimViewTag })
            let snapshotView = containerView.subviews.first(where: { $0.tag == KagomeTransitionController.snapshotViewTag })
            
            UIView.animate(withDuration: duration, animations: {
                dimView?.alpha = 0.0
                snapshotView?.transform = .identity
                toController.view.transform = .identity
                
                fromController.view.layer.cornerRadius = self.cornerRadius
                fromController.view.layer.masksToBounds = true
                snapshottedFromView.layer.cornerRadius = self.cornerRadius
                snapshottedFromView.layer.masksToBounds = true
                toController.view.layer.cornerRadius = self.cornerRadius
                toController.view.layer.masksToBounds = true
                
                fromController.view.frame = CGRect(x: 0.0,
                                                   y: containerView.bounds.height,
                                                   width: containerView.bounds.width,
                                                   height: containerView.bounds.height)
            }, completion: { _ in
                dimView?.removeFromSuperview()
                snapshotView?.removeFromSuperview()
                fromController.view.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
    }
}
