//
//  Dictionary Models.swift
//  Mac Chord Suggester
//
//  Created by Carlos Mbendera on 13/11/2022.
//

import Foundation

public let NumberOfNotes = 12
public let SequenceLength = 20
public let SuggestedChordNumber = 7

public let ToComponents = getQualityToComponents()
public let ToNumber = getNoteToValue()
public let ToNote = getValueToNote()

func getValueToNote() -> [String: Any]{
    
    var valueToNote = [String : Any]()
    
    if let path = Bundle.main.path(forResource: "value_to_note", ofType: "json", inDirectory: "dictionaries") {
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let object = try JSONSerialization.jsonObject(with: data) as? [String : Any]
            valueToNote = object!
            
        } catch let error {
            print("parse error: \(error.localizedDescription)")
        }
    } else { print("Invalid filename/path.") }
    
    return valueToNote
}

func getChordKeys() -> [String: Any]{
    
    var categoryTonumber = [String : Any]()
    
    if let path = Bundle.main.path(forResource: "category_to_number", ofType: "json", inDirectory: "dictionaries") {
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let object = try JSONSerialization.jsonObject(with: data) as? [String : Any]
            categoryTonumber = object!
            
        } catch let error {
            print("parse error: \(error.localizedDescription)")
        }
    } else { print("Invalid filename/path.") }
    
    return categoryTonumber
}

func getNoteToValue() -> [String: Any]{
    
    var noteToValue = [String : Any]()
    
    if let path = Bundle.main.path(forResource: "note_to_value", ofType: "json", inDirectory: "dictionaries") {
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let object = try JSONSerialization.jsonObject(with: data) as? [String : Any]
            noteToValue = object!
            
        } catch let error {
            print("parse error: \(error.localizedDescription)")
        }
    } else { print("Invalid filename/path.") }
    
    return noteToValue
}

func getQualities() -> [String]{
    
    var qualities = [String]()
    
    if let path = Bundle.main.path(forResource: "unique_qualities", ofType: "json", inDirectory: "dictionaries") {
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let object = try JSONSerialization.jsonObject(with: data) as? [String]
            qualities = object!
            
        } catch let error {
            print("parse error: \(error.localizedDescription)")
        }
    } else { print("Invalid filename/path.") }
    
    return qualities
}

func getQualityToComponents() -> [String : Any]{
    
    var qualitiesToComponents = [String : Any]()
    
    if let path = Bundle.main.path(forResource: "quality_to_components", ofType: "json", inDirectory: "dictionaries") {
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let object = try JSONSerialization.jsonObject(with: data) as? [String : Any]
            qualitiesToComponents = object!
            
        } catch let error {
            print("parse error: \(error.localizedDescription)")
        }
    } else { print("Invalid filename/path.") }
    
    return qualitiesToComponents
}

