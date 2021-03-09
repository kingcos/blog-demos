//
//  ViewController.swift
//  UIButton-demo
//
//  Created by kingcos on 2020/9/10.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var titleTopPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        titleTopPicker.dataSource = self
    }
    
    
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        "1"
    }
}
