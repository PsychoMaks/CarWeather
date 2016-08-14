//
//  CarCreationViewController
//  SkywellCarWeather
//
//  Created by Maks Sergeychuk on 8/11/16.
//  Copyright © 2016 company.com. All rights reserved.
//

import UIKit
import ImageSlideshow

class CarInfoViewController: UIViewController {


    @IBOutlet var imageSlideShowView: ImageSlideshow!
    @IBOutlet var carNameLabel: UILabel!
    @IBOutlet var carPriceLabel: UILabel!
    @IBOutlet var carEngineLabel: UILabel!
    @IBOutlet var carTransmissionLabel: UILabel!
    @IBOutlet var carConditionLabel: UILabel!
    @IBOutlet var carDescriptionTextView: UITextView!
    
    var transitionDelegate: ZoomAnimatedTransitioningDelegate?
    var carItem: Car?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        imageSlideShowView.slideshowInterval = 5.0
        imageSlideShowView.pageControlPosition = PageControlPosition.UnderScrollView
        imageSlideShowView.pageControl.currentPageIndicatorTintColor = UIColor.whiteColor();
        imageSlideShowView.pageControl.pageIndicatorTintColor = UIColor.lightGrayColor();
        
        self.title = carItem?.name
        self.configureView()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(click))
        imageSlideShowView.addGestureRecognizer(recognizer)
    }
    
    func configureView() {
        if let car = carItem {
            carNameLabel.text = car.name
            carPriceLabel.text = car.price
            carEngineLabel.text = car.engine
            carTransmissionLabel.text = car.transmission
            carConditionLabel.text = car.condition
            carDescriptionTextView.text = car.desc
            var imagesArray = [ImageSource]()
            if car.photos?.count > 0 {
                car.photos?.enumerateObjectsUsingBlock({ (photo, nil) in
                    if let aPhoto = photo as? CarPhoto {
                        imagesArray.append(ImageSource(image: UIImage(data: aPhoto.imageData!)!))
                    }
                })
                if imagesArray.count > 0 {
                    imageSlideShowView.setImageInputs(imagesArray)
                }
            }
        }
    }
    
    func click() {
        
        let ctr = FullScreenSlideshowViewController()
        ctr.pageSelected = {(page: Int) in
            self.imageSlideShowView.setScrollViewPage(page, animated: false)
        }
        
        ctr.initialPage = imageSlideShowView.scrollViewPage
        ctr.inputs = imageSlideShowView.images
        self.transitionDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: imageSlideShowView)
        ctr.transitioningDelegate = self.transitionDelegate
        self.presentViewController(ctr, animated: true, completion: nil)
    }
}

