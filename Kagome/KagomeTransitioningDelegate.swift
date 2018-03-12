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
    public var roundCorners: Bool = false
    public var cornerRadius: CGFloat = 8.0
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return KagomeTransitionController(isPresenting: true,
                                          shouldCover: shouldCoverSourceController,
                                          roundCorners: roundCorners,
                                          cornerRadius: cornerRadius)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return KagomeTransitionController(isPresenting: false,
                                          shouldCover: shouldCoverSourceController,
                                          roundCorners: roundCorners,
                                          cornerRadius: cornerRadius)
    }
}

public final class KagomeTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - KagomeTransitionController
    
    private let isPresenting: Bool
    private let shouldCover: Bool
    private let roundCorners: Bool
    private let cornerRadius: CGFloat
    
    public init(isPresenting presenting: Bool,
                shouldCover: Bool,
                roundCorners: Bool = false,
                cornerRadius: CGFloat = 8.0) {
        self.isPresenting = presenting
        self.shouldCover = shouldCover
        self.roundCorners = roundCorners
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
    private var oldCornerRadius: CGFloat = 0.0
    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.0
        view.tag = self.dimViewTag
        return view
    }()
    private let dimViewTag: Int = 33295761735
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        
        guard let fromController = transitionContext.viewController(forKey: .from),
              let toController = transitionContext.viewController(forKey: .to) else { return }
        
        if isPresenting {
            containerView.addSubview(dimView)
            dimView.frame = containerView.bounds
            containerView.addSubview(toController.view)
            toController.view.frame = CGRect(x: 0.0,
                                             y: containerView.bounds.height,
                                             width: containerView.bounds.width,
                                             height: containerView.bounds.height)
            oldCornerRadius = fromController.view.layer.cornerRadius
            
            UIView.animate(withDuration: duration, animations: {
                if self.roundCorners {
                    fromController.view.layer.cornerRadius = self.cornerRadius
                    fromController.view.layer.masksToBounds = true
                }
                
                self.dimView.alpha = 0.6
                
                fromController.view.transform = {
                    if fromController.view.frame == containerView.bounds {
                        let scale = CGAffineTransform(scaleX: self.scaleFactor * 0.97, y: self.scaleFactor * 0.96)
                        let translate = CGAffineTransform(translationX: 0.0, y: self.rearViewTranslation(isFirst: true))
                        return scale.concatenating(translate)
                    } else {
                        let scale = CGAffineTransform(scaleX: self.scaleFactor, y: self.scaleFactor)
                        let translate = CGAffineTransform(translationX: 0.0, y: self.rearViewTranslation(isFirst: false))
                        return scale.concatenating(translate)
                    }
                }()
                
                if self.shouldCover {
                    toController.view.frame = transitionContext.finalFrame(for: toController)
                } else {
                    toController.view.frame = transitionContext.finalFrame(for: toController).offsetBy(dx: 0.0, dy: self.modalTopDistance)
                }
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        } else {
            let dimView = containerView.subviews.first(where: { $0.tag == self.dimViewTag })
            UIView.animate(withDuration: duration, animations: {
                toController.view.transform = CGAffineTransform.identity
                toController.view.layer.cornerRadius = self.oldCornerRadius
                fromController.view.frame = CGRect(x: 0.0,
                                                   y: containerView.bounds.height,
                                                   width: containerView.bounds.width,
                                                   height: containerView.bounds.height)
                dimView?.alpha = 0.0
            }, completion: { _ in
                dimView?.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
    }
}
