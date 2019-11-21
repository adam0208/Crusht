//
//  SwipingPhotosController.swift
//  Crusht
//
//  Created by William Kelly on 12/10/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Nuke

class SwipingPhotosController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    let isCardViewMode: Bool
    let deselectedBarColor = UIColor(white: 0, alpha: 0.1)
    let barsStackView = UIStackView(arrangedSubviews: [])
    
    var controllers = [UIViewController]()
    
    var cardViewModel: CardViewModel! {
        didSet {
            print(cardViewModel.attributedString)
            controllers = cardViewModel.imageUrls.map { (imageUrl) -> UIViewController in
                let photoController = PhotoController(imageUrl: imageUrl)
                return photoController
            }
            
            setViewControllers([controllers.first!], direction: .forward, animated: false)
            setupBarViews()
        }
    }
    
    // MARK: - Life Cycle Methods
    
    init(isCardViewMode: Bool = false) {
        self.isCardViewMode = isCardViewMode
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        view.backgroundColor = .white
        delegate = self
        //setViewControllers([controllers.first!], direction: .forward, animated: false)
        
        if isCardViewMode {
            disableSwipingAbility()
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Logic
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        let currentController = viewControllers!.first!
        if let index = controllers.firstIndex(of: currentController) {
            barsStackView.arrangedSubviews.forEach({$0.backgroundColor = deselectedBarColor})

            if gesture.location(in: self.view).x > view.frame.width/2 {
                let nextIndex = min(index + 1, controllers.count - 1)
                let nextController = controllers[nextIndex]
                setViewControllers([nextController], direction: .forward, animated: false)
                //barsStackView.arrangedSubviews.forEach({$0.backgroundColor = deselectedBarColor})
                barsStackView.arrangedSubviews[nextIndex].backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
            } else {
                let prevIndex = max(0, index - 1)
                let prevController = controllers[prevIndex]
                setViewControllers([prevController], direction: .forward, animated: false)
                //barsStackView.arrangedSubviews.forEach({$0.backgroundColor = deselectedBarColor})
                barsStackView.arrangedSubviews[prevIndex].backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
            }
        }
    }
    
    private func disableSwipingAbility () {
        view.subviews.forEach { (v) in
            if let v = v as? UIScrollView {
                v.isScrollEnabled = false
            }
        }
    }
    
    // MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentPhotoController = viewControllers?.first
        if let index = controllers.firstIndex(where: {$0 == currentPhotoController}) {
            barsStackView.arrangedSubviews.forEach({$0.backgroundColor = deselectedBarColor})
            barsStackView.arrangedSubviews[index].backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == controllers.count - 1 { return nil }
        return controllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == 0 { return nil }
        return controllers[index - 1]
    }
    
    // MARK: - User Interface
    
    private func setupBarViews() {
        cardViewModel.imageUrls.forEach { _ in
            let barView = UIView()
            barView.backgroundColor = deselectedBarColor
            barView.layer.cornerRadius = 4
            barsStackView.addArrangedSubview(barView)
        }
        barsStackView.arrangedSubviews.first?.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
        view.addSubview(barsStackView)
        let paddingTop: CGFloat = 8
        barsStackView.anchor(top: view.topAnchor,
                             leading: view.leadingAnchor,
                             bottom: nil,
                             trailing: view.trailingAnchor,
                             padding: .init(top: paddingTop, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
    }
}

import Nuke

private class PhotoController: UIViewController {
    let imageView = UIImageView(image: #imageLiteral(resourceName: "CrushtLogoLiam"))
    
    init(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            Nuke.loadImage(with: url, into: imageView)
            //imageView.sd_setImage(with: url)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
