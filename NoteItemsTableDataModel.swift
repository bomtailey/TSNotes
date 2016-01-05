//
//  NoteItemsTableDataModel.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/12/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit

class NoteItemsTableDataModel: NSObject {
    
    //Properties
    var sections:[String] = []
    var items:[[String]] = []
    
    
    func addSection(section: String, item:[String]){
        sections = sections + [section]
        items = items + [item]
    }

}

class specificNoteItems: NoteItemsTableDataModel {
    override init() {
        super.init()
        
        addSection("5:12 am", item: ["This is a sample note item text"])
        addSection("7:32 pm", item: ["This is another sample note text"])
        addSection("7:32 pm", item: ["This is another sample note text"])
        addSection("7:32 pm", item: ["This is another sample note text"])
        addSection("7:32 apm", item: ["This is another sample note text"])
        addSection("10:15 pm", item: ["And this is yet another sample note text entry " +
            "A web view object displays web-based content. It is an instance of the UIWebView class that" +
            "enables you to integrate what is essentially a miniature web browser into your app’s user interface." +
            "The UIWebView class makes full use of the same web technologies used to implement Safari in iOS, including" +
            "full support for" +
      " HTML, CSS, and JavaScript content. The class also supports many of the built-in gestures that users are familiar with in" + "Safari. For example, you can double-click and pinch to zoom in and out of the page and you can scroll around the" +
        "page by dragging your finger." +
           " In addition to displaying content, you can also use a web view object to gather input from the user through the" +
            "use of web forms. Like the other text classes in UIKit, if you have an editable text field on a form in your" +
            "web page, tapping that field brings up a keyboard so that the user can enter text. Because it is an integral" +
            "part of the web experience, the web view itself manages the displaying and dismissing of the keyboard for you." +
            "Figure 1-2 shows an example of a UIWebView object from the UIKit Catalog (iOS): Creating and Customizing UIKit Controls sample app, which demonstrates many of the views and controls available in UIKit. Because it just displays HTML content, if you want the user to be able to navigate pages much like they would in a web browser, you need to add controls to do so."])
    }
}
