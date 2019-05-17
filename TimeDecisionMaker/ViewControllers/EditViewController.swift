//
//  EditViewController.swift
//  TimeDecisionMaker
//
//  Created by Marina Lunts on 5/15/19.
//

import UIKit

class EditViewController: UIViewController {
    
    public var selectedEvent = Appointment()
    public var selectedPerson: Person?
    
    private var formatter = DateFormatter()
    private let datePicker = UIDatePicker()
    private let durationPicker = UIDatePicker()
    
    @IBOutlet weak var dateStartTextfield: UITextField!
    @IBOutlet weak var dateEndTextfield: UITextField!
    @IBOutlet weak var durationLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
    }
    
    private func updateUI() {
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        dateStartTextfield.text = formatter.string(from: selectedEvent.dateInterval.start)
        dateEndTextfield.text = formatter.string(from: selectedEvent.dateInterval.end)
        durationLabel.text = selectedEvent.durarationToString(dateInterval: selectedEvent.dateInterval)
        
        datePicker.datePickerMode = .dateAndTime
        addToolBar(dateTextfield: dateStartTextfield, datePicker: datePicker)
        addToolBar(dateTextfield: dateEndTextfield, datePicker: datePicker)
        
        durationPicker.datePickerMode = .countDownTimer
        addToolBar(dateTextfield: durationLabel, datePicker: durationPicker)
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        if Service().dateViladation(startDate: Appointment().convertStringToDate(value: dateStartTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm"), endDate: Appointment().convertStringToDate(value: dateEndTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm")) {
            selectedEvent.dateInterval.start = selectedEvent.convertStringToDate(value: dateStartTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm")
            selectedEvent.dateInterval.end = selectedEvent.convertStringToDate(value: dateEndTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm")
            if Service().saveEditedObjectToICSFile(object: selectedEvent, resourceFile: selectedPerson?.ICSPath ?? "A") {
            } else {
                let alert: UIAlertController = UIAlertController(title: "Error!", message: "File cannot be edited :(", preferredStyle: .alert)
                let okAction: UIAlertAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(okAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert: UIAlertController = UIAlertController(title: "Error!", message: "Event's start date cannot be later than  event's end date!", preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    private func addToolBar(dateTextfield: UITextField, datePicker: UIDatePicker) {
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        var doneButton = UIBarButtonItem()
        if dateTextfield == dateStartTextfield {
            doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneStartDatePicker));
        } else if dateTextfield == dateEndTextfield {
            doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneEndDatePicker));
        } else if dateTextfield == durationLabel {
            doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDurationPicker));
        }
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        dateTextfield.inputAccessoryView = toolbar
        dateTextfield.inputView = datePicker
    }
    
    @objc func doneStartDatePicker(){
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        dateStartTextfield.text = formatter.string(from: datePicker.date)
        if Service().dateViladation(startDate: Appointment().convertStringToDate(value: dateStartTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm"), endDate: Appointment().convertStringToDate(value: dateEndTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm")) {
            durationLabel.text = "\(DateInterval(start: Appointment().convertStringToDate(value: dateStartTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm"), end: Appointment().convertStringToDate(value: dateEndTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm")).duration)"
        } else {
            durationLabel.text = "0h"
        }
        self.view.endEditing(true)
    }
    
    @objc func doneEndDatePicker(){
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateEndTextfield.text = formatter.string(from: datePicker.date)
        if Service().dateViladation(startDate: Appointment().convertStringToDate(value: dateStartTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm"), endDate: Appointment().convertStringToDate(value: dateEndTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm")) {
            durationLabel.text = "\(selectedEvent.durarationToString(dateInterval: DateInterval(start: Appointment().convertStringToDate(value: dateStartTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm"), end: Appointment().convertStringToDate(value: dateEndTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm"))))"
        } else {
            durationLabel.text = "0h"
        }
        self.view.endEditing(true)
    }
    
    @objc func doneDurationPicker() {
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        durationLabel.text = selectedEvent.durarationToString(dateInterval: DateInterval(start: Appointment().convertStringToDate(value: dateStartTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm"), duration: durationPicker.countDownDuration))
        dateEndTextfield.text = formatter.string(from: DateInterval(start: Appointment().convertStringToDate(value: dateStartTextfield.text!, timezone: "Europe/Kiev", format: "dd/MM/yyyy HH:mm"), duration: durationPicker.countDownDuration).end)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    
    
}

