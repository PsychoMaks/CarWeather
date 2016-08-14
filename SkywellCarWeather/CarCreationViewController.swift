//
//  CarCreationViewController.swift
//  SkywellCarWeather
//
//  Created by Maks Sergeychuk on 8/12/16.
//  Copyright © 2016 company.com. All rights reserved.
//

import UIKit
import Photos
import CoreData

protocol CarCreationDelegate {
    func newCarCreated(car: Car)
}

class CarCreationViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet var carNameTextField: UITextField!
    @IBOutlet var carPriceTextField: UITextField!
    @IBOutlet var engineTextField: UITextField! {
        didSet{ configureForPickerView(engineTextField) }
    }
    @IBOutlet var transmissionTextField: UITextField!{
        didSet{ configureForPickerView(transmissionTextField) }
    }
    @IBOutlet var conditionTextField: UITextField!{
        didSet{ configureForPickerView(conditionTextField) }
    }
    @IBOutlet var carDescriptionTextView: UITextView!
    @IBOutlet var collectionView: UICollectionView!
    
    let imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        return picker
    }()
    var carImages = [UIImage]()
    
    
    var carEngines = [String]()
    var carTransmissions = [String]()
    var carCondition = [String]()
        
    var currentPickerArray: [String]?
    var currentTextField: UITextField?
    
    let pickerView = UIPickerView()
    let toolBar: UIToolbar =  {
       let toolbar = UIToolbar(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        toolbar.tintColor = UIColor.lightGrayColor()
        return toolbar
    }()
    
    var delegate: CarCreationDelegate?
    var tap: UITapGestureRecognizer?
    
    
    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        pickerView.dataSource = self
        pickerView.delegate = self
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let button = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .Done, target: self, action: #selector(doneButtonPressed))
        toolBar.setItems([space,button], animated: false)
        
        collectionView.registerNib(UINib(nibName: "CarCreationImageViewCell", bundle: nil), forCellWithReuseIdentifier: CarCreationImageViewCell.identifier)
        collectionView.registerNib(UINib(nibName: "CarCreationNewImageViewCell", bundle: nil), forCellWithReuseIdentifier: CarCreationNewImageViewCell.identifier)
        
        carEngines = ["600cc","1000cc",NSLocalizedString("1000cc disel", comment: ""), "1500cc","2500cc", "5000cc"]
        carTransmissions = [NSLocalizedString("Manual", comment: ""),NSLocalizedString("Automatic", comment: ""),NSLocalizedString("TripTronic", comment: "")]
        carCondition = [NSLocalizedString("Best", comment: ""),NSLocalizedString("Good", comment: ""),NSLocalizedString("Normal", comment: ""),NSLocalizedString("Bad", comment: ""),NSLocalizedString("Trash", comment: "")]
        
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    }
    
    func dismissKeyboard() {
        view.removeGestureRecognizer(tap!)
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func addCarButtonPressed(sender: UIBarButtonItem) {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        view.endEditing(true)
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            if let newCar = NSEntityDescription.insertNewObjectForEntityForName("Car", inManagedObjectContext: context) as? Car {
                newCar.id = NSUUID().UUIDString
                newCar.name = (self.carNameTextField.text?.isEmpty == false) ? self.carNameTextField.text : NSLocalizedString("Unknown", comment: "")
                if self.carPriceTextField.text?.isEmpty == false {
                    newCar.price = self.carPriceTextField.text! + "$"
                } else {
                    newCar.price = NSLocalizedString("Specify", comment: "")
                }
                
                newCar.condition = self.conditionTextField.text
                newCar.engine = self.engineTextField.text
                newCar.transmission = self.transmissionTextField.text
                newCar.desc = self.carDescriptionTextView.text
                if self.carImages.count > 0 {
                    for image in self.carImages {
                        if let newCarPhoto = NSEntityDescription.insertNewObjectForEntityForName("CarPhoto", inManagedObjectContext: context) as? CarPhoto {
                            newCarPhoto.imageData = UIImagePNGRepresentation(image)
                            newCarPhoto.car = newCar
                        }
                    }
                }
                
                self.delegate?.newCarCreated(newCar)
            } else {
                print("Error when tryin to create new car")
            }
        })
        self.navigationController?.popViewControllerAnimated(true)  
    }
    
    func configureForPickerView(textField: UITextField) {
        textField.inputView = pickerView
        textField.inputAccessoryView = toolBar
    }
    
    func doneButtonPressed() {
        currentTextField?.text = currentPickerArray![pickerView.selectedRowInComponent(0)]
        view.removeGestureRecognizer(tap!)
        currentTextField?.resignFirstResponder()
    }
}

extension CarCreationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate {
    //MARK: - DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carImages.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if carImages.count > 0 && indexPath.row < carImages.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CarCreationImageViewCell.identifier, forIndexPath: indexPath) as! CarCreationImageViewCell
            cell.imageView.image = carImages[indexPath.row]
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CarCreationNewImageViewCell.identifier, forIndexPath: indexPath) as! CarCreationNewImageViewCell
        return cell
    }
    
    //MARK: - Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            carImages.append(pickedImage)
            collectionView.reloadData()
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CarCreationViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        view.addGestureRecognizer(tap!)
        if textField == engineTextField {
            currentTextField = textField
            currentPickerArray = carEngines
            pickerView.reloadAllComponents()
        } else if textField == transmissionTextField {
            currentTextField = textField
            currentPickerArray = carTransmissions
            pickerView.reloadAllComponents()
        } else if textField == conditionTextField {
            currentTextField = textField
            currentPickerArray = carCondition
            pickerView.reloadAllComponents()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.removeGestureRecognizer(tap!)
        textField.resignFirstResponder()
        return false
    }
}

extension CarCreationViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentPickerArray?.count ?? 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentPickerArray![row]
    }
}
