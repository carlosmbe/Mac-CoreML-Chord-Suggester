//
//  ContentView.swift
//  Mac Chord Suggester
//
//  Created by Carlos Mbendera on 12/11/2022.
//

import SwiftUI

struct ContentView: View {
    
    @State private var chords = [Float32]()
    @State private var chordsString = ""
    @State private var prediction = ""
  
    @State private var selectedChord = "C3"
    
    @State private var selectedRoot = "C"
    @State private var selectedQuality = "3"

    private let roots = ["C","Db","D","Eb","E","F","F#","G","Ab","A","Bb","B"]
    private let qualities = getQualities().sorted()
    
    private let categoryTonumber = getChordKeys()
    
    var body: some View {
        
        VStack {
            
            HStack {
                Picker("Pick Root", selection: $selectedRoot){
                    ForEach(roots, id:\.self){ Text($0) }
                }
                
                Picker("Pick Quality", selection: $selectedQuality){
                    ForEach(qualities, id:\.self){ Text($0) }
                }
                
            }//HStack Ends Here
            
            HStack {
                Button("Add Chord"){
                    selectedChord = "\(selectedRoot)\(selectedQuality)"
                    print(selectedChord)
                    chords.append(categoryTonumber[selectedChord] as! Float32)
                    chordsString = "\(chordsString)          \(selectedChord)"
                }.padding()
                
                Button("Clear List"){
                    chords.removeAll()
                    chordsString = ""
                    prediction = ""
                }.padding()
            }
            VStack{
                Text("Current Progression : ").font(.headline)
                
                Text(chordsString).bold().padding([.bottom, .top])
            }
          
            Text("The Likely Chords Are \n \(prediction)")
            
        }
        .onChange(of: chords, perform: { newValue in
            if !newValue.isEmpty {
                print("Not Empty")
                prediction = predict(for: chords)
            }
        })
        .padding()
        .frame(width: 750, height: 500)
    }
    
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

