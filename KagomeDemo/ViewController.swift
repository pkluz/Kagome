//
//  ViewController.swift
//  KagomeDemo
//
//  Created by Philip Kluz on 2018-03-11.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import UIKit
import Kagome

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(presentButton)
        view.addSubview(pushButton)
        
        view.backgroundColor = {
            let r = CGFloat(arc4random_uniform(255))
            let g = CGFloat(arc4random_uniform(255))
            let b = CGFloat(arc4random_uniform(255))
            return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
        }()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.presentingViewController != nil {
            view.addSubview(dismissButton)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        presentButton.frame = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 50.0)
        presentButton.center = CGPoint(x: view.center.x, y: view.center.y - 55.0)
        
        dismissButton.frame = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 50.0)
        dismissButton.center = CGPoint(x: view.center.x, y: view.center.y)
        
        pushButton.frame = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 50.0)
        pushButton.center = CGPoint(x: view.center.x, y: view.center.y + 55.0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if (self.presentingViewController != nil) && self.transitioningDelegate is KagomeTransitioningDelegate {
            return .lightContent
        }
        
        return .default
    }
    
    private lazy var presentButton: UIButton = {
        let button = UIButton()
        button.setTitle("Present Modal", for: .normal)
        button.addTarget(self, action: #selector(presentModal), for: .touchUpInside)
        button.backgroundColor = .green
        return button
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("Dismiss Modal", for: .normal)
        button.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        button.backgroundColor = .red
        return button
    }()
    
    private lazy var pushButton: UIButton = {
        let button = UIButton()
        button.setTitle("Push View", for: .normal)
        button.addTarget(self, action: #selector(pushView), for: .touchUpInside)
        button.backgroundColor = .red
        return button
    }()
    
    private lazy var modalTransitioningDelegate: KagomeTransitioningDelegate = {
        let delegate = KagomeTransitioningDelegate()
        delegate.cornerRadius = 12.0
        delegate.roundCorners = true
        return delegate
    }()
    
    @objc func dismissModal() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func pushView() {
        navigationController?.pushViewController(ViewController(), animated: true)
    }
    
    @objc func presentModal() {
        let controller = ViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.transitioningDelegate = modalTransitioningDelegate
        navigationController.modalPresentationCapturesStatusBarAppearance = true
        navigationController.modalPresentationStyle = .custom

        present(navigationController, animated: true, completion: nil)
    }
}
