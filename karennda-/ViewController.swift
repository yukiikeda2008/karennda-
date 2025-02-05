//
//  ViewController.swift
//  karennda-
//
//  Created by 池田友希 on 2025/01/29.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var headerPrevBtn: UIButton!//1
    @IBOutlet weak var headerNextBtn: UIButton!//2
    @IBOutlet weak var headerTitle: UILabel!  //3
    @IBOutlet weak var calenderHeaderView: UIView! //4
    @IBOutlet weak var calenderCollectionView: UICollectionView!//5
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    //①タップ時
    @IBAction func tappedHeaderPrevBtn (sender: UIButton) {
        
        
        //②タップ時
        @IBAction func tappedHeaderNextBtn (sender: UIButton) {
        }
        
    }
    
    import UIKit
    
    class CakenderCell: UICollectionViewCell {
        
        ver textLabel: UILabel!
        
        repuired init(coder aDecoder: NSCoder) {
            super. init(coder: aDecoder)!
            
            //UILabelを作成
            textLabel = UILabel(frame: CGRectMake(0,0,self.frame.width,self . feame . height))
            textLabel. font = UIFont (name: "HoraKAkuProN-W3", size:12)
            textLabel?.textAlignment = NSTextAlignment.Center
            //Cellに追加
            self.addSubview(textLabel!)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
            
                                                  
        }
    }
