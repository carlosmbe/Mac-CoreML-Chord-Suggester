//
//  Models.swift
//  Mac Chord Suggester
//
//  Created by Carlos Mbendera on 12/11/2022.
//
import CoreML
import Foundation

struct ChordProbability: Hashable {
    var name: String
    var probability: Float
}

func predict(for chords: [Float32]) -> [ChordProbability] {
    do {
        let config = MLModelConfiguration()
        let model = try MLChordSuggester(configuration: config)
        
        let mlArray = convertToMLArray(chords)
        let modelInput = MLChordSuggesterInput(embedding_13_input: mlArray)
        
        guard let modelOutput = try? model.prediction(input: modelInput) else {
            fatalError("Unexpected runtime error with predict output.")
        }
        
        return convertPredictToChords(for: modelOutput)
    } catch {
        print("Prediction did not work")
        fatalError("Prediction Failed")
    }
}

func convertToMLArray(_ input: [Float32]) -> MLMultiArray {
    let mlArray = try! MLMultiArray(shape: [1,20], dataType: .float32)
    
    for (index, element) in input.enumerated() {
        mlArray[index] = NSNumber(value: Double(element))
    }
    
    return mlArray
}

func convertPredictToChords(for modelOutput: MLChordSuggesterOutput) -> [ChordProbability] {
    let numberToCategory = loadNumberToCategory()
    
    var probabilities = [Float]()
    for i in 0..<modelOutput.Identity.count {
        probabilities.append(modelOutput.Identity[i].floatValue)
    }
    
    // Remove the probability for null chord
    let _ = probabilities.removeFirst()
    
    var chordProbabilities = [ChordProbability]()
    
    for (index, value) in probabilities.enumerated() {
        let name = numberToCategory["\(index+1)"] as! String
        chordProbabilities.append(ChordProbability(name: name, probability: value))
    }
    
    chordProbabilities.sort { $0.probability > $1.probability }
    
    return Array(chordProbabilities.prefix(7))
}


func loadNumberToCategory() -> [String: Any] {
    if let path = Bundle.main.path(forResource: "number_to_category", ofType: "json", inDirectory: "dictionaries") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            if let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return object
            }
        } catch let error {
            print("parse error: \(error.localizedDescription)")
        }
    } else {
        print("Invalid filename/path.")
    }
    return [:]
}
