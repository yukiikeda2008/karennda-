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

import UIKit

extension UIColor {
    class func lightBlue() -> UIColor {
        return UIColor (red: 92.0 / 255, green: 192.0 / 255, blue: 210,0 / 255, alpha: 1.0)
    }
    class func lightRed() -> UIColor {
        return UIColor(red: 195.0 / 255, green: 123.0 / 255, blue: 175.0 / 255, alpha: 1.0)
    }
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    let dateManager = dateManager()
    let daysPerweed: Int = 7
    let cellMargin: CGFloat = 2.0
    var selectedDate = NSDate()
    var today: NSDate!
    let weekArray = ["Sun", "Mon", "Tue","Wed","Thu","Fri","Sat"]
    
    @IBOutlet weak var headerPrevBtn: UIButton!//①
    @IBOutlet weak var headerNextBtu: UIButton!//②
    @IBOutlet weak var headerTitle: UILabel!   //③
    @IBOutlet weak var calenderHeaderView: UIView! //④
    @IBOutlet weak var celenderCollectionView: UICollectionView! // ⑤
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calenderCollectionView.delegate = self
        calenderCollectionView.dataSource = self
        calenderCollectionView.backgroundColor = UIColor.whiteColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated
    }
    
    //1
    func numberOfSections(collectionView: UICollectionView) -> Int {
        return 2
        
    }
    //2
    func collectionView(collectionView: UICollectionView, umberOfItemsInSection section: Int) -> Int {
        //Section毎にCellの総数を変える
        if section == 0{
            return 7
        } else{
            return dateManager.daysAcquisition()
        }
    }
    //3
    func collectionView(_ collectionView: UICollectionView, cellForItemArIndxPath indexpath: NSIndexPath) -> UICollectionViewCell{
        
        return cell
    } 
    <#code#>
    }
