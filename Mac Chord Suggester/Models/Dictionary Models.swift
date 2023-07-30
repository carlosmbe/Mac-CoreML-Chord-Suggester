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

public let categoryTonumber = loadDictionary(from: "category_to_number")
public let ToComponents = loadDictionary(from: "quality_to_components")
public let ToNumber = loadDictionary(from: "note_to_value")
public let ToNote = loadDictionary(from: "value_to_note")
public let ToChord = loadDictionary(from: "number_to_category")

func loadDictionary(from resourceName: String) -> [String: Any] {
    var dictionary = [String: Any]()
    if let path = Bundle.main.path(forResource: resourceName, ofType: "json", inDirectory: "dictionaries") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            if let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                dictionary = object
            }
        } catch let error {
            print("parse error: \(error.localizedDescription)")
        }
    } else {
        print("Invalid filename/path for resource: \(resourceName).")
    }
    return dictionary
}

func getQualities() -> [String] {
    var qualities = [String]()
    if let path = Bundle.main.path(forResource: "unique_qualities", ofType: "json", inDirectory: "dictionaries") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            if let object = try JSONSerialization.jsonObject(with: data) as? [String] {
                qualities = object
            }
        } catch let error {
            print("parse error: \(error.localizedDescription)")
        }
    } else {
        print("Invalid filename/path for resource: unique_qualities.")
    }
    return qualities
}
