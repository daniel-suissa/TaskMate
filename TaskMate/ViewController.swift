//
//  ViewController.swift
//  TaskMate
//
//  Created by Daniel Suissa on 9/10/16.
//  Copyright © 2016 Daniel Suissa. All rights reserved.
//

import GoogleAPIClient
import GTMOAuth2
import UIKit
import Foundation

class ViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    private let kKeychainItemName = "Google Calendar API"
    private let kClientID = "667939645668-ep7euiuc8eof5lr7fdh4inrdg9i3cck9.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLAuthScopeCalendarReadonly]
    
    private let service = GTLServiceCalendar()
    let output = UITextView()
    
    
    @IBOutlet weak var task_name_field: UITextField!
    
    @IBOutlet weak var minutesPicker: UIPickerView!

    @IBOutlet weak var hoursPicker: UIPickerView!
    
    
    @IBOutlet weak var importancePicker: UIPickerView!
    
    
    
    @IBOutlet weak var deadlinePicker: UIDatePicker!
    

    //variables for json
    var hours = 0;
    var minutes = 0;
    var importance_level = 2;
    var deadline = "";
    var taskName: String? = "";
    
    var timeSlots : [[String:AnyObject]] = []
    
    
    var hoursOptions = [Int]()
    var hoursPickerData = [String]()
    var minutesOptions = [Int]()
    var minutesPickerData = [String]()
    var importances = [String]()
    
    let testDic: [[String:AnyObject]] = [
        [
            "task_desc": "#1",
            "task_duration": 100,
            "task_importance": "medium importance",
            "task_deadline": "2016-09-12 22:30"
        ],
        [
            "task_desc": "#2",
            "task_duration": 20,
            "task_importance": "medium importance",
            "task_deadline": "2016-09-13 10:30"
        ],
        [
            "task_desc": "#3",
            "task_duration": 40,
            "task_importance": "medium importance",
            "task_deadline": "2016-09-13 14:30"
        ]
        
    ]
 //667939645668-ep7euiuc8eof5lr7fdh4inrdg9i3cck9.apps.googleusercontent.com

    override func viewDidLoad() {
        super.viewDidLoad()
        
        output.frame = view.bounds
        output.editable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        view.addSubview(output);
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }

        
        
        // Do any additional setup after loading the view, typically from a nib.
        hoursPicker.dataSource = self
        hoursPicker.delegate = self
        
        minutesPicker.dataSource = self
        minutesPicker.delegate = self
        
        importancePicker.dataSource = self
        importancePicker.delegate = self
        
        for index in 0...12{
            hoursOptions.append(index);
            hoursPickerData.append("" + String(index) + " hours")
        }
        for index in 0...59{
            minutesOptions.append(index);
            minutesPickerData.append("" + String(index) + " minutes")
        }
        hoursPicker.tag = 1;
        minutesPicker.tag = 2;
        importancePicker.tag = 3;
        importances = ["Low", "Medium" ,"High"]
    }
    
    func titleAlert(){
        print("titleAlert")
        let alertController = UIAlertController(title: "Input Error", message: "You must enter a task title", preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    func durationAlert(){
        print("durationAlert")
        let alertController = UIAlertController(title: "Input Error", message: "Duration must be between 5 minutes and 3 hours", preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    func post_request(content:[[String:AnyObject]] , urlstring :String){
        do {
        
        let jsonData = try NSJSONSerialization.dataWithJSONObject(content, options: .PrettyPrinted)
        
        // create post request
        let url = NSURL(string: urlstring + "/tasks")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        // insert json data to the request
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonData
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
        if error != nil{
            print("Error -> \(error)")
            return
        }
        
            do {
            let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
        
            print("Result -> \(result)")
        
            } catch {
                print("Error -> \(error)")
            }
        }
        task.resume()
        } catch {
            print(error)
    }
    }
    
    @IBAction func submit(sender: UIButton) {
        //process the date
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        var strDate = dateFormatter.stringFromDate(deadlinePicker.date)
        
        deadline = strDate
        
        var duration = minutes + 60 * hours;
        taskName = task_name_field.text;
        
        if (taskName == ""){
            titleAlert();
            return;
        }
        //duration validation
        if(duration < 5 || duration > 180){
            durationAlert()
            return
        }
        
        //create json
        let json: [[String:AnyObject]] = [
            [
                "task_desc": task_name_field.text!,
                "task_duration": duration,
                "task_importance": importance_level,
                "task_deadline": deadline
            ]
        ]
        print(json);
        
        post_request(timeSlots, urlstring: "localhost")
        post_request(json, urlstring: "localhost");
        

    }

    
    @IBAction func refreshFeed(sender: UIButton) {
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 1){
            return hoursPickerData.count
        }
        else if (pickerView.tag == 2){
            return minutesPickerData.count
        }
        else{
            return importances.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.tag == 1){
            return hoursPickerData[row]
        }
        else if (pickerView.tag == 2){
            return minutesPickerData[row]
        }
        else {
            return importances[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 1){
            hours =  hoursOptions[row]
        }else if (pickerView.tag == 2){
            minutes = minutesOptions[row]
        }
        else{
            importance_level = row;
        }
    }
    // When the view appears, ensure that the Google Calendar API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            fetchEvents()
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    // Construct a query and get a list of upcoming events from the user calendar
    func fetchEvents() {
        let query = GTLQueryCalendar.queryForEventsListWithCalendarId("primary")
        query.maxResults = 50;
        query.timeMin = GTLDateTime(date: NSDate(), timeZone: NSTimeZone.localTimeZone())
        query.singleEvents = true
        query.orderBy = kGTLCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: "displayResultWithTicket:finishedWithObject:error:"
        )
    }
    
    
    //infers duration between two time strings
    func timeInMinutes(start:String,end:String)->Int{
        let startMinVal = Int(start.substringToIndex(start.startIndex.advancedBy(2)))!*60 + Int(start.substringFromIndex(start.startIndex.advancedBy(3)))!
        let endMinVal = Int(end.substringToIndex(end.startIndex.advancedBy(2)))!*60 + Int(end.substringFromIndex(end.startIndex.advancedBy(3)))!
        return endMinVal-startMinVal
    }
    
    //take a day string and return the next
    func incrementDay(dayString:String)->String{
        let yearAndMonth = dayString.substringToIndex(dayString.startIndex.advancedBy(8))
        let day = Int(dayString.substringFromIndex(dayString.startIndex.advancedBy(8)))
        return yearAndMonth + String(day!+1)
    }
    // Display the start dates and event summaries in the UITextView
    func displayResultWithTicket(
        ticket: GTLServiceTicket,
        finishedWithObject response : GTLCalendarEvents,
                           error : NSError?) {
        
        if let error = error {
            showAlert("Error", message: error.localizedDescription)
            return
        }
        
        var eventTimesArray = [[String]]()
        if let events = response.items() where !events.isEmpty {
            for event in events as! [GTLCalendarEvent] {
                
                if var startString = event.start.JSON["dateTime"]?.componentsSeparatedByString("T"){
                    
                
                    print (startString)
                    let startDate:String? = startString[0]
                    var r = startString[1].startIndex.advancedBy(5)
                    let startTime = startString[1].substringToIndex(r)
                    
                    let endString = event.end.JSON["dateTime"]?.componentsSeparatedByString("T")
                    let endDate = endString![0];
                    r = endString![1].startIndex.advancedBy(5)
                    let endTime = endString![1].substringToIndex(r)
                    
                    eventTimesArray.append([startDate!,startTime,endDate,endTime])
                }
                
            }
        }
        
        
        var positionInSlots = -1;
        for index in 0...eventTimesArray.count{//enumerate and make sure to go until one before last
            var event = eventTimesArray[index]
            var nextEvent = eventTimesArray[index+1]
            if(index == eventTimesArray.count-2){
                break
            }
            
            if(timeInMinutes(event[3], end: "20:00") <= 0) {continue}
            timeSlots.append(["start_time": (event[2] + " " + event[3]), "duration" : 0])
            positionInSlots += 1
            if(nextEvent[0] != event[0]){
                //complete today
                let r1 = nextEvent[0].startIndex.advancedBy(8)
                let r2 = event[0].startIndex.advancedBy(8)
                
                var days = Int(nextEvent[0].substringFromIndex(r1))!-Int(event[0].substringFromIndex(r2))!
                
                timeSlots[positionInSlots]["duration"] = timeInMinutes(event[3], end: "20:00")
                
                var daytoComplete = incrementDay(event[0])
                
                //complete all days until next event if more than tomorrow
                while(days > 1){
                    timeSlots.append(["start_time" : daytoComplete + " 08:00","duration": 720])
                    positionInSlots += 1
                    daytoComplete = incrementDay(daytoComplete)
                    days -= 1
                }
                //complete tomorrow until next event
                if(timeInMinutes(nextEvent[1], end: "08:00")>=0){continue}
                timeSlots.append(["start_time" : nextEvent[0] + " 08:00","duration": timeInMinutes("08:00", end: nextEvent[1])])
                positionInSlots += 1
                
            }
            else{
                timeSlots[positionInSlots]["duration"] = timeInMinutes(event[3], end: nextEvent[3])
                //just do next event, no need to append, use positionInSlots
            }
            
        }
        print(timeSlots)
        
    }
    
    
    // Creates the auth controller for authorizing access to Google Calendar API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: "viewController:finishedWithAuth:error:"
        )
    }
    
    // Handle completion of the authorization process, and update the Google Calendar API
    // with the new credentials.
    func viewController(vc : UIViewController,
                        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert("Authentication Error", message: error.localizedDescription)
            return
        }
        
        service.authorizer = authResult
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: nil
        )
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

