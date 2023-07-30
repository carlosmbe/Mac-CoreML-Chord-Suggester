//
//  ContentView.swift
//  Mac Chord Suggester
//
//  Created by Carlos Mbendera on 12/11/2022.
//

import SwiftUI

struct ContentView: View {
    
    @State private var chords = [Float32]()
    @State private var chordsNames = [String]()
    @State private var midiChords = [[UInt8]]()
    
    @State private var predictionArray = [ChordProbablity]()
    
    @State private var selectedChord = "C"
    @State private var selectedRoot = "C"
    @State private var selectedQuality = ""
    
    private let roots = ["C","Db","D","Eb","E","F","F#","G","Ab","A","Bb","B"]
    private var qualities = getQualities().sorted()
    
    func test(){
        for _ in 0...17{
            chords.append(Float32.random(in: 1...800))
            print(chords.count)
            predictionArray = predict(for: chords)
        }
        chords.removeAll()
    }
    
    var body: some View {
        
        VStack {
            Button("Test", action: test)
            
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
                    let name = "\(selectedRoot)\(selectedQuality)"
                    addChord(name: name)
                }.padding()
                
                Button("Clear List"){
                    withAnimation{
                        chords.removeAll()
                        chordsNames.removeAll()
                        midiChords.removeAll()
                        predictionArray.removeAll()
                    }
                }.padding()
                
            }//HStack Ends Here
            if !chordsNames.isEmpty{
                VStack{
                    Text("Current Progression : ").font(.headline)
                    
                    HStack{
                        ForEach(chordsNames.indices, id: \.self){
                            chordProgressionItem(item: self.chordsNames[$0])
                        }
                    }
                    
                    Button("Play"){
                        if !midiChords.isEmpty{ createPlayer(chords: midiChords) }
                    }
                    .padding([.bottom, .top])
                    
                }//VStack Ends Here
                
                Text("The Likely Chords")
                
                HStack{
                    ForEach(predictionArray, id: \.self) { chord in
                        VStack{
                            suggestedChord(chord: chord)
                            Button{
                                addChord(name: "\(chord.name)")
                            }label: {
                                Image(systemName: "plus.circle")
                            }
                        }
                    }
                }//HSTack ends here
            }//If Ends here
            

        }
        .onChange(of: chords, perform: { newValue in
            if !newValue.isEmpty {
                    predictionArray = predict(for: chords)
            }
        })
        
        .padding()
        .frame(width: 850, height: 500)
        
    }//Main VStack Ends Here
    
    func addChord(name: String){
        if chords.count < 20{
            withAnimation{
                chords.append(categoryTonumber[name] as! Float32)
                chordsNames.append(name)
                // chordsString = "\(chordsString)  \(name),"
                let chordNotesType = ChordNotes(name: name)
                let rawNotes = chordNotesType.getNotes()
                let midiNotes = covertChordNotesToMidi(notes: rawNotes)
                midiChords.append(midiNotes)
            }
        }
    }
}



struct suggestedChord : View{
    
    let chord : ChordProbablity
    
    var body: some View{
        VStack{
            Text(chord.name)
                .font(.headline)
            
            Text("% \(Int(chord.probability*100))")
                .font(.headline)
            
            Button(){
                let chordNotesType = ChordNotes(name: chord.name)
                let rawNotes = chordNotesType.getNotes()
                let midiNotes = covertChordNotesToMidi(notes: rawNotes)
                var midiChords = [[UInt8]]()
                midiChords.append(midiNotes)
                createPlayer(chords: midiChords)
            }label: {
                Image(systemName: "play.circle")
            }
        }
    }
}

struct chordProgressionItem : View{
    
    let item : String
    
    var body : some View{
        VStack{
            Text(item)
                .font(.headline)
                .bold()
            
            Button{
                let chordNotesType = ChordNotes(name: item)
                let rawNotes = chordNotesType.getNotes()
                let midiNotes = covertChordNotesToMidi(notes: rawNotes)
                var midiChords = [[UInt8]]()
                midiChords.append(midiNotes)
                createPlayer(chords: midiChords)
            }label: {
                Image(systemName: "play.circle")
            }
        }
        
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

