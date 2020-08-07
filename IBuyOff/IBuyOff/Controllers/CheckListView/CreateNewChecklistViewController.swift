//
//  CreateNewChecklistViewController.swift
//  IBuyOff
//
//  Created by Mohanraj on 03/08/20.
//  Copyright © 2020 ThirdwareSolutions. All rights reserved.
//

import UIKit
import Alamofire
import iOSDropDown
//import SVProgressHUD

struct CheckListData: Decodable {
    let dieSetNo: String
    let buyOffType : String?
    let programNo: String?
    let partName: String?
    let partNo: String?
    let supplier: String?
    let plant: String?
    let dieLineUpNo1: String?
    let dieLineUpNo2: String?
    let dieLineUpNo3: String?
    let dieLineUpNo4: String?
    let dieLineUpNo5: String?
    let dieLineUpNo6: String?
    let buyOffTypeLst: BuyOffTypeList
    let errMsg: String?
    let errFlg: Bool?
    enum CodingKeys: String, CodingKey {
      case dieSetNo
      case buyOffType
      case programNo
      case partName
      case partNo
      case supplier
      case plant
      case dieLineUpNo1
      case dieLineUpNo2
      case dieLineUpNo3
      case dieLineUpNo4
      case dieLineUpNo5
      case dieLineUpNo6
      case buyOffTypeLst
      case errMsg
      case errFlg

    }
}

struct PostCheckListData: Decodable {
    let dieSetNo: String?
    let buyOffType: String?
    let programNo: String?
    let partName: String?
    let partNo: String?
    let supplier: String?
    let plant: String?
    let dieLineUpNo1: String?
    let dieLineUpNo2: String?
    let dieLineUpNo3: String?
    let dieLineUpNo4: String?
    let dieLineUpNo5: String?
    let dieLineUpNo6: String?
    let buyOffTypeLst: BuyOffTypeList?
    let errMsg: String?
    let errFlg: String?
    
    enum CodingKeys: String, CodingKey {
        case dieSetNo
        case buyOffType
        case programNo
        case partName
        case partNo
        case supplier
        case plant
        case dieLineUpNo1
        case dieLineUpNo2
        case dieLineUpNo3
        case dieLineUpNo4
        case dieLineUpNo5
        case dieLineUpNo6
        case buyOffTypeLst
        case errMsg
        case errFlg
    }
}

struct BuyOffTypeList: Decodable {
    let FBO: String?
    let PS: String?
    let OTS: String?
    
    enum CodingKeys: String, CodingKey {
        case FBO
        case PS
        case OTS
    }
}

enum buyoff: String {
    case FBO
    case PS
    case OTS
}

class CreateNewChecklistViewController: UIViewController {
    
    let checkListsfetchPreDataUrl = "https://buyoffservice.cfapps.io/BuyOff/chcklst/predata"
    let checkListsPostUrl = "https://buyoffservice.cfapps.io/BuyOff/chcklst/insertdata"
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var programTextField: DropDown!
    @IBOutlet weak var productionPlantTextField: DropDown!
    @IBOutlet weak var partNameTextField: DropDown!
    @IBOutlet weak var partTextField: UITextField!
    @IBOutlet weak var diesetNumberTextField: UITextField!
    @IBOutlet weak var toolSupplierTextField: UITextField!
    @IBOutlet weak var diesetlineupTextField: UITextField!
    @IBOutlet weak var buyOffTypeTextField: DropDown!
    @IBOutlet weak var checkListScrollView: UIScrollView!
   
    var programs = [String]()
    var ProductionPlants = [String]()
    var partNames = [String]()
    var checkLists = [CheckListData]()
    var programSelectString: String?
    var buyoffList = [String]()
    var partNameSelectString: String?
    var productionPlantselectString: String?
    var buyOffSelectingSting: String?
    var dieLineUpNo1String: String?
    var dieLineUpNo2String: String?
    var dieLineUpNo3String: String?
    var dieLineUpNo4String: String?
    var dieLineUpNo5String: String?
    var dieLineUpNo6String: String?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        self.isValidation(index: 0)
        self.fetchTheCheckListsPredata()
        self.returnKeyforTextfield()
        programTextField.didSelect{(selectedText , index ,id) in
            
        self.programSelectString = selectedText
        let filterTheProgramNo = self.checkLists.filter({Check in return Check.programNo == selectedText})
            print("Select string:\(selectedText)")
            print(filterTheProgramNo)
            self.isValidation(index: 1)
            self.selectProductionPlant(checkList: filterTheProgramNo)
        }
            
            self.buyOffTypeTextField.didSelect{(selectedText, index, id) in
            print(selectedText)
                if selectedText == "FBO"{
                    self.buyOffTypeTextField.text = "Final BuyOff"
                }
                else if selectedText == "PS" {
                    self.buyOffTypeTextField.text = "Pre-Static"
                }
                else if selectedText == "OTS"{
                    self.buyOffTypeTextField.text = "Ok to Ship"
                }
                self.buyOffSelectingSting = selectedText
                
                
            
            self.isValidation(index: 8)
                }
    }
    
    func selectProductionPlant(checkList:[CheckListData]) {
         var filterproductionPlant = [String]()
        for plant in checkList {
            filterproductionPlant.append(plant.plant ?? "")
        }
        self.ProductionPlants = filterproductionPlant.unique()
        productionPlantTextField.optionArray = self.ProductionPlants
        productionPlantTextField.didSelect { (selectedText, index, id) in
            self.isValidation(index: 2)
            print(selectedText)
            self.productionPlantselectString = selectedText
            
            let filterThePartName = self.checkLists.filter({Check in return Check.plant == selectedText && Check.programNo == self.programSelectString})
           
            self.selectPartName(checkList: filterThePartName)
        }
        
    }
    
    func selectPartName(checkList:[CheckListData]) {
        var filterpartName = [String]()
        for partName in checkList {
            filterpartName.append(partName.partName ?? "")
        }
        
        self.partNames = filterpartName.unique()
        partNameTextField.optionArray = self.partNames
        partNameTextField.didSelect { (selectedText, index, id) in
            self.isValidation(index: 3)
            self.partNameSelectString = selectedText
                   print(selectedText)
            self.fillTheRemainingField()
            }
        
    }
    
    func fillTheRemainingField() {
        let partNumbers = self.checkLists.filter({Check in return Check.partName == self.partNameSelectString && Check.programNo == self.programSelectString && Check.plant == self.productionPlantselectString})
        
        print(partNumbers)
        
         self.isValidation(index: 7)
         
        if (partNumbers.count > 0){
             dieLineUpNo1String = partNumbers[0].dieLineUpNo1
             dieLineUpNo2String = partNumbers[0].dieLineUpNo2
             dieLineUpNo3String = partNumbers[0].dieLineUpNo3
             dieLineUpNo4String = partNumbers[0].dieLineUpNo4
             dieLineUpNo5String = partNumbers[0].dieLineUpNo5
             dieLineUpNo6String = partNumbers[0].dieLineUpNo6
            
            self.partTextField.text = partNumbers[0].partNo
            self.diesetNumberTextField.text = partNumbers[0].dieSetNo
            self.diesetlineupTextField.text = "\(dieLineUpNo1String ?? ""),\(dieLineUpNo2String ?? ""),\(dieLineUpNo3String ?? ""),\(dieLineUpNo4String ?? ""),\(dieLineUpNo5String ?? ""),\(dieLineUpNo6String ?? "")"
            self.toolSupplierTextField.text = partNumbers[0].supplier
        }

    }
    
    func backgroundColorChange(textField: UITextField,color: UIColor, isUserEnable: Bool){
        
        textField.backgroundColor = color
        textField.isUserInteractionEnabled = isUserEnable
        
        if isUserEnable == false{
            textField.text = ""
        }
        
    }
    func isValidation(index:Int) {
        switch index {
        case 0:
            backgroundColorChange(textField: productionPlantTextField, color:.gray ,isUserEnable: false)
                  
            backgroundColorChange(textField: partNameTextField, color:.gray ,isUserEnable: false)
                      
            backgroundColorChange(textField: partTextField, color:.gray ,isUserEnable: false)
                      
            backgroundColorChange(textField: diesetNumberTextField, color:.gray ,isUserEnable: false)
                  
            backgroundColorChange(textField: diesetlineupTextField, color:.gray ,isUserEnable: false)
                      
            backgroundColorChange(textField: toolSupplierTextField, color:.gray ,isUserEnable: false)
                      
            backgroundColorChange(textField: buyOffTypeTextField, color: .gray, isUserEnable: false)
            continueButton.backgroundColor = UIColor.init(red: 0, green: 166/255, blue: 98/255, alpha: 0.6)
             continueButton.isUserInteractionEnabled = false
            
            break
            
        case 1:
             backgroundColorChange(textField: productionPlantTextField, color:.white ,isUserEnable: true)
                   
             backgroundColorChange(textField: partNameTextField, color:.gray ,isUserEnable: false)
                       
                   backgroundColorChange(textField: partTextField, color:.gray ,isUserEnable: false)
                       
                   backgroundColorChange(textField: diesetNumberTextField, color:.gray ,isUserEnable: false)
                   
                   backgroundColorChange(textField: diesetlineupTextField, color:.gray ,isUserEnable: false)
                       
                   backgroundColorChange(textField: toolSupplierTextField, color:.gray ,isUserEnable: false)
                       
                   backgroundColorChange(textField: buyOffTypeTextField, color: .gray, isUserEnable: false)
             continueButton.backgroundColor = UIColor.init(red: 0, green: 166/255, blue: 98/255, alpha: 0.6)
              continueButton.isUserInteractionEnabled = false
       break
        case 2:
            backgroundColorChange(textField: productionPlantTextField, color:.white ,isUserEnable: true)
                  
            backgroundColorChange(textField: partNameTextField, color:.white ,isUserEnable: true)
                      
                  backgroundColorChange(textField: partTextField, color:.gray ,isUserEnable: false)
                      
                  backgroundColorChange(textField: diesetNumberTextField, color:.gray ,isUserEnable: false)
                  
                  backgroundColorChange(textField: diesetlineupTextField, color:.gray ,isUserEnable: false)
                      
                  backgroundColorChange(textField: toolSupplierTextField, color:.gray ,isUserEnable: false)
                      
                  backgroundColorChange(textField: buyOffTypeTextField, color: .gray, isUserEnable: false)
            continueButton.backgroundColor = UIColor.init(red: 0, green: 166/255, blue: 98/255, alpha: 0.6)
             continueButton.isUserInteractionEnabled = false
            break
        
            
        case 3:
        
         backgroundColorChange(textField: productionPlantTextField, color:.white ,isUserEnable: true)
               
         backgroundColorChange(textField: partNameTextField, color:.white ,isUserEnable: true)
                   
               backgroundColorChange(textField: partTextField, color:.white ,isUserEnable: true)
                   
               backgroundColorChange(textField: diesetNumberTextField, color:.gray ,isUserEnable: false)
               
               backgroundColorChange(textField: diesetlineupTextField, color:.gray ,isUserEnable: false)
                   
               backgroundColorChange(textField: toolSupplierTextField, color:.gray ,isUserEnable: false)
                   
               backgroundColorChange(textField: buyOffTypeTextField, color: .gray, isUserEnable: false)
         continueButton.backgroundColor = UIColor.init(red: 0, green: 166/255, blue: 98/255, alpha: 0.6)
          continueButton.isUserInteractionEnabled = false
            break
        case 4:
            
        backgroundColorChange(textField: productionPlantTextField, color:.white ,isUserEnable: true)
                      
                backgroundColorChange(textField: partNameTextField, color:.white ,isUserEnable: true)
                          
                      backgroundColorChange(textField: partTextField, color:.white ,isUserEnable: true)
                          
                      backgroundColorChange(textField: diesetNumberTextField, color:.white ,isUserEnable: true)
                      
                      backgroundColorChange(textField: diesetlineupTextField, color:.gray ,isUserEnable: false)
                          
                      backgroundColorChange(textField: toolSupplierTextField, color:.gray ,isUserEnable: false)
                          
                      backgroundColorChange(textField: buyOffTypeTextField, color: .gray, isUserEnable: false)
        continueButton.backgroundColor = UIColor.init(red: 0, green: 166/255, blue: 98/255, alpha: 0.6)
         continueButton.isUserInteractionEnabled = false
            break
            
            case 5:
                
            backgroundColorChange(textField: productionPlantTextField, color:.white ,isUserEnable: true)
                          
                    backgroundColorChange(textField: partNameTextField, color:.white ,isUserEnable: true)
                              
                          backgroundColorChange(textField: partTextField, color:.white ,isUserEnable: true)
                              
                          backgroundColorChange(textField: diesetNumberTextField, color:.white ,isUserEnable: true)
                          
                          backgroundColorChange(textField: diesetlineupTextField, color:.white ,isUserEnable: true)
                              
                          backgroundColorChange(textField: toolSupplierTextField, color:.gray ,isUserEnable: false)
                              
                          backgroundColorChange(textField: buyOffTypeTextField, color: .gray, isUserEnable: false)
            continueButton.backgroundColor = UIColor.init(red: 0, green: 166/255, blue: 98/255, alpha: 0.6)
             continueButton.isUserInteractionEnabled = false
                break
            
            case 6:
                
            backgroundColorChange(textField: productionPlantTextField, color:.white ,isUserEnable: true)
                          
                    backgroundColorChange(textField: partNameTextField, color:.white ,isUserEnable: true)
                              
                          backgroundColorChange(textField: partTextField, color:.white ,isUserEnable: true)
                              
                          backgroundColorChange(textField: diesetNumberTextField, color:.white ,isUserEnable: true)
                          
                          backgroundColorChange(textField: diesetlineupTextField, color:.white ,isUserEnable: true)
                              
                          backgroundColorChange(textField: toolSupplierTextField, color:.white ,isUserEnable: true)
                              
                          backgroundColorChange(textField: buyOffTypeTextField, color: .gray, isUserEnable: false)
            continueButton.backgroundColor = UIColor.init(red: 0, green: 166/255, blue: 98/255, alpha: 0.6)
            continueButton.isUserInteractionEnabled = false
                break
         case 7:
                        
                    backgroundColorChange(textField: productionPlantTextField, color:.white ,isUserEnable: true)
                                  
                            backgroundColorChange(textField: partNameTextField, color:.white ,isUserEnable: true)
                                      
                                  backgroundColorChange(textField: partTextField, color:.white ,isUserEnable: true)
                                      
                                  backgroundColorChange(textField: diesetNumberTextField, color:.white ,isUserEnable: true)
                                  
                                  backgroundColorChange(textField: diesetlineupTextField, color:.white ,isUserEnable: true)
                                      
                                  backgroundColorChange(textField: toolSupplierTextField, color:.white ,isUserEnable: true)
                                      
                                  backgroundColorChange(textField: buyOffTypeTextField, color: .white, isUserEnable: true)
                     continueButton.backgroundColor = UIColor.init(red: 0, green: 166/255, blue: 98/255, alpha: 0.6)
                     continueButton.isUserInteractionEnabled = false
                    
                        break
            case 8:
                
            backgroundColorChange(textField: productionPlantTextField, color:.white ,isUserEnable: true)
                          
                    backgroundColorChange(textField: partNameTextField, color:.white ,isUserEnable: true)
                              
                          backgroundColorChange(textField: partTextField, color:.white ,isUserEnable: true)
                              
                          backgroundColorChange(textField: diesetNumberTextField, color:.white ,isUserEnable: true)
                          
                          backgroundColorChange(textField: diesetlineupTextField, color:.white ,isUserEnable: true)
                              
                          backgroundColorChange(textField: toolSupplierTextField, color:.white ,isUserEnable: true)
                              
                          backgroundColorChange(textField: buyOffTypeTextField, color: .white, isUserEnable: true)
            continueButton.backgroundColor = UIColor.init(red: 0, green: 166/255, blue: 98/255, alpha: 1.0)
            continueButton.isUserInteractionEnabled = true
            
                break
                 
           default:
          backgroundColorChange(textField: productionPlantTextField, color:.gray ,isUserEnable: false)
                
          backgroundColorChange(textField: partNameTextField, color:.gray ,isUserEnable: false)
                    
          backgroundColorChange(textField: partTextField, color:.gray ,isUserEnable: false)
                    
          backgroundColorChange(textField: diesetNumberTextField, color:.gray ,isUserEnable: false)
                
          backgroundColorChange(textField: diesetlineupTextField, color:.gray ,isUserEnable: false)
                    
          backgroundColorChange(textField: toolSupplierTextField, color:.gray ,isUserEnable: false)
                    
                backgroundColorChange(textField: buyOffTypeTextField, color: .gray, isUserEnable: false)
          continueButton.backgroundColor = UIColor.init(red: 0, green: 166/255, blue: 98/255, alpha: 0.6)
            break
    }
    }
    
    func isValidationForCheckList() -> Bool {
        var isValidation:Bool = true
        if programTextField.text == ""{
            isValidation = false
        }
        if productionPlantTextField.text == ""{
            isValidation = false
        }
        if partNameTextField.text == ""{
            isValidation = false
        }
        if partTextField.text == "" {
            isValidation = false
        }
        
        if diesetNumberTextField.text == ""{
            isValidation = false
        }
        if diesetlineupTextField.text == "" {
            isValidation = false
        }
        if toolSupplierTextField.text == "" {
            isValidation = false
        }
        if buyOffTypeTextField.text == "" {
            isValidation = false
        }
        return isValidation
    }
    func saveThePostCheckLists() {
         
        if isValidationForCheckList(){
         // SVProgressHUD.show()
            
            let paramenter:[String: Any] = ["dieSetNo":diesetNumberTextField.text ?? "","buyOffType":buyOffSelectingSting ?? "","programNo":programTextField.text ?? "","partName":partNameTextField.text ?? "","partNo":partTextField.text ?? "","supplier":toolSupplierTextField.text ?? "","plant":productionPlantTextField.text ?? "","dieLineUpNo1":dieLineUpNo1String ?? "" ,"dieLineUpNo2": dieLineUpNo2String ?? "","dieLineUpNo3":dieLineUpNo3String ?? "" ,"dieLineUpNo4":dieLineUpNo4String ?? "","dieLineUpNo5":dieLineUpNo5String ?? "","dieLineUpNo6":dieLineUpNo6String ?? ""]
            print(paramenter)
            AF.request(checkListsPostUrl,method: .post, parameters:paramenter,encoding: JSONEncoding.default)
//                   .responseDecodable(of: PostCheckListData.self) { (response) in
                .responseJSON{ response in
                    
                    switch response.result {
                    case let .success(result):
                        print(result)
                        
                        //SVProgressHUD.dismiss()
                    case let .failure(error):
                        print(error)
                        //SVProgressHUD.dismiss()

                    }
                   }
        }
        else {
           // alertmessage(message: "")
        }
       
    }
    func alertmessage(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        self.present(alert, animated: true)
    }

    func returnKeyforTextfield()
    {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 1, height: 1))
        programTextField.inputView = view
        productionPlantTextField.inputView = view
        partNameTextField.inputView = view
        partTextField.inputView = view
        diesetNumberTextField.inputView = view
        diesetlineupTextField.inputView = view
        toolSupplierTextField.inputView = view
        buyOffTypeTextField.inputView = view
        
//        programTextField.returnKeyType = .done
//        productionPlantTextField.returnKeyType = .done
//        partNameTextField.returnKeyType = .done
//        partTextField.returnKeyType = .done
//        diesetNumberTextField.returnKeyType = .done
//        toolSupplierTextField.returnKeyType = .done
//        diesetlineupTextField.returnKeyType = .done
//        buyOffTypeTextField.returnKeyType = .done
    }
  
    func fetchTheCheckListsPredata(){
        //SVProgressHUD.show()
        AF.request(checkListsfetchPreDataUrl,method: .get)
            .responseDecodable(of: [CheckListData].self) { (response) in

                    switch response.result {
                    case let .success(result):
                        print(result)
                        self.checkLists = result
                        var filterprogram = [String]()
                        
                        for value in result {
                        filterprogram.append(value.programNo ?? "")
                        }
                        print(filterprogram)
                        self.programs = filterprogram.unique()
                        self.programTextField.optionArray = self.programs
                        self.buyOffTypeTextField.optionArray = ["FBO","PS","OTS"]
                        //SVProgressHUD.dismiss()
                    case let .failure(error):
                        print(error)
                        //SVProgressHUD.dismiss()

                    }
                }
        }
    
    @IBAction func continueAction(_ sender: Any) {
           self.saveThePostCheckLists()
       }
    
    //    @objc func keyboardWillShow(notification:NSNotification){
    //
    //        let userInfo = notification.userInfo!
    //        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    //        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
    //
    //        var contentInset:UIEdgeInsets = self.checkListScrollView.contentInset
    //        contentInset.bottom = keyboardFrame.size.height + 25
    //        checkListScrollView.contentInset = contentInset
    //    }
    //
    //    @objc func keyboardWillHide(notification:NSNotification){
    //
    //        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
    //        checkListScrollView.contentInset = contentInset
    //    }
}

extension CreateNewChecklistViewController: UITextFieldDelegate {
//    private func textFieldDidBeginEditing(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return false
//    }
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return false
//    }
}
extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
