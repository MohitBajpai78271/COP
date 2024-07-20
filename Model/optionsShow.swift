//
//  optionsShow.swift
//  ConstableOnPatrol
//
//  Created by Mac on 13/07/24.
//
import UIKit

class optionsShow: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let options = [
    "option1","option2","option3"
    ]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedOption = options[row]
        print(selectedOption)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        view.addSubview(pickerView)
    }
    
}
