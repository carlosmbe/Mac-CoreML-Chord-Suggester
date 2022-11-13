//
//  Models.swift
//  Mac Chord Suggester
//
//  Created by Carlos Mbendera on 12/11/2022.
//
import CoreML
import Foundation

struct ChordProbablity {
    var name: String
    var probability : Float
}


func predict(for chords: [Float32]) -> String{
    do{
        let config = MLModelConfiguration()
        let model = try MLChordSuggester(configuration: config)

        /*
         This Code Works Perfectly fine and I wrote it from Scratch but the next one using the function is short,lean and mean
         
         //Use category numbers for chords, like from 0 to 804 in the JSON
         var inputArray = [[Float32]]()
         
         inputArray.append(chords)
         
         var mlArray = try! MLMultiArray(shape: [1,20], dataType: .float32)
         
         for batchIndex in 0..<1 {
         for chordIndex in 0..<inputArray[batchIndex].count {
         print(batchIndex)
         mlArray[[batchIndex, chordIndex] as [NSNumber]] = (inputArray[batchIndex][chordIndex]) as NSNumber
         }
         }
         */
        
        var alternativeInputArray = convertToMLArray(chords)
    
        let modelInput = MLChordSuggesterInput(embedding_13_input: alternativeInputArray)
       
        guard let modelOutput = try? model.prediction(input: modelInput) else {
            fatalError("Unexpected runtime error with predict output.")
        }
    
        return convertPredictToChords(for: modelOutput)
        
    }catch{
        print("Prediction did not work")
    }
    
    fatalError("Prediction Failed")
}

func convertToMLArray(_ input: [Float32]) -> MLMultiArray {

    let mlArray = try? MLMultiArray(shape: [1,20], dataType: MLMultiArrayDataType.float32)

    for (index, element) in input.enumerated() {
            mlArray![index] = NSNumber(value: Double(element))
        }

       return mlArray!
   }




func convertPredictToChords(for modelOutput : MLChordSuggesterOutput) -> String{
 
    var numberToCategory = [String : Any]()
    
    var probabilitiesOutputFloatArray = [Float]()
    
    var output = ""
    
    for i in 0..<modelOutput.Identity.count  {
        probabilitiesOutputFloatArray.append(modelOutput.Identity[i].floatValue)
        
        output =  "\(output) \(modelOutput.Identity[i].self)  \n"
    }
    
    if let path = Bundle.main.path(forResource: "number_to_category", ofType: "json", inDirectory: "dictionaries") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let object = try JSONSerialization.jsonObject(with: data) as? [String : Any]
            numberToCategory = object!
            
        } catch let error {
            print("parse error: \(error.localizedDescription)")
        }
    } else {
        print("Invalid filename/path.")
    }
    
    //.shift() equal. I am reverse engineering the java script code. This remove probability for null chord
    //  print("Before = \(probabilitiesOutputFloatArray.count)")
    let shiftPlaceHolder = probabilitiesOutputFloatArray.removeFirst()
    //   print("After Place = \(probabilitiesOutputFloatArray.count)")
    
    //   print("This is shiftPlaceHolder = \(shiftPlaceHolder)")
    
    //Converting numbers to chords
    var chordProbs = [ChordProbablity]()
    
    //Assign Chords
    for index in 0..<probabilitiesOutputFloatArray.count{
        let value = probabilitiesOutputFloatArray[index]
        let name = numberToCategory["\(index+1)"]
        //+1 Cause no zero in the json dictionary
        chordProbs.append(ChordProbablity(name: name as! String, probability: value))
    }
    
    
    //Sort Chords By Probs
    chordProbs.sort { left, right in
        /*OG JAva Script This means decending order,
         hihgest to lowest, b-a, right - left
         right.probability - left.probability
         */
        left.probability > right.probability
    }
    
    
    //idk if this slices proper like :   chordProbabilities = chordProbabilities.slice(0,Constants.SuggestedChordNumber);
    let slice = chordProbs.prefix(7)
    
    //Test Output
    var chordOutput = ""
    for i in slice{
        chordOutput = "\(chordOutput) \(i.name) = %\(i.probability * 100) \n"
    }
    
    return chordOutput
    
}


