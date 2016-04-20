//
//  DisplayFeedImageViewController.swift
//  barr
//
//  Created by Carl Lin on 4/11/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class DisplayFeedImageViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!;
    var mainImage: UIImage!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainImageView.image = mainImage;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
