//
//  WatchImageVC.swift
//  Medical Care
//
//  Created by Jesus Reynaga Rodriguez on 28/05/18.
//  Copyright © 2018 Jesus Reynaga Rodriguez. All rights reserved.
//

import UIKit

class WatchImageVC: UIViewController, UIScrollViewDelegate
{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var ads_catch = UIImage()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        self.imageView.image = ads_catch
    }
    
    @IBAction func closeView(_ sender: UIPanGestureRecognizer)
    {
        UIView.animate(withDuration: 0.3, animations: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func closeViewPicture(_ sender: UISwipeGestureRecognizer)
    {
        UIView.animate(withDuration: 0.9, animations: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return self.imageView
    }
}
