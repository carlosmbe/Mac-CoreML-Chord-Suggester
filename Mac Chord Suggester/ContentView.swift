//
//  ContentView.swift
//  Mac Chord Suggester
//
//  Created by Carlos Mbendera on 12/11/2022.
//
import SwiftUI

struct ContentView: View {
    // State variables
    @State private var chords: [Float32] = []
    @State private var chordsNames: [String] = []
    @State private var midiChords: [[UInt8]] = []
    @State private var predictionArray: [ChordProbability] = []
    @State private var selectedRoot: String = "C"
    @State private var selectedQuality: String = ""

    // Constants
    private let roots = ["C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
    private var qualities: [String] { getQualities().sorted() }

    // Body
    var body: some View {
        VStack {
            controlsSection
            if !chordsNames.isEmpty {
                chordProgressSection
                predictionSection
            }
        }
        .onChange(of: chords) { _ in
            if !chords.isEmpty {
                predictionArray = predict(for: chords)
            }
        }
        .padding()
        .frame(width: 850, height: 500)
    }
}

// MARK: - ContentView Subviews
extension ContentView {
    private var controlsSection: some View {
        VStack {
            Button("Test", action: test)
            HStack {
                Picker("Pick Root", selection: $selectedRoot) {
                    ForEach(roots, id: \.self) { Text($0) }
                }
                Picker("Pick Quality", selection: $selectedQuality) {
                    ForEach(qualities, id: \.self) { Text($0) }
                }
            }
            HStack {
                Button("Add Chord") {
                    addChord(name: "\(selectedRoot)\(selectedQuality)")
                }.padding()
                Button("Clear List") {
                    withAnimation {
                        chords.removeAll()
                        chordsNames.removeAll()
                        midiChords.removeAll()
                        predictionArray.removeAll()
                    }
                }.padding()
            }
        }
    }

    private var chordProgressSection: some View {
        VStack {
            Text("Current Progression : ").font(.headline)
            HStack {
                ForEach(chordsNames.indices, id: \.self) { index in
                    ChordProgressionItem(item: chordsNames[index])
                }
            }
            Button("Play") {
                if !midiChords.isEmpty { createPlayer(chords: midiChords) }
            }
            .padding([.bottom, .top])
        }
    }

    private var predictionSection: some View {
        VStack {
            Text("The Likely Chords")
            HStack {
                ForEach(predictionArray, id: \.self) { chord in
                    VStack {
                        SuggestedChord(chord: chord)
                        Button {
                            addChord(name: "\(chord.name)")
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
        }
    }

    // Helpers
    private func test() {
        for _ in 0...17 {
            chords.append(Float32.random(in: 1...800))
            predictionArray = predict(for: chords)
        }
        chords.removeAll()
    }

    private func addChord(name: String) {
        if chords.count < 20 {
            withAnimation {
                chords.append(categoryTonumber[name] as! Float32)
                chordsNames.append(name)
                let chordNotes = ChordNotes(name: name)
                let midiNotes = convertChordNotesToMidi(notes: chordNotes.getNotes())
                midiChords.append(midiNotes)
            }
        }
    }
}

struct SuggestedChord: View {
    let chord: ChordProbability

    var body: some View {
        VStack {
            Text(chord.name).font(.headline)
            Text("% \(Int(chord.probability * 100))").font(.headline)
            Button {
                playChord(name: chord.name)
            } label: {
                Image(systemName: "play.circle")
            }
        }
    }
}

struct ChordProgressionItem: View {
    let item: String

    var body: some View {
        VStack {
            Text(item).font(.headline).bold()
            Button {
                playChord(name: item)
            } label: {
                Image(systemName: "play.circle")
            }
        }
    }
}

// Helper function for the chord-related views
func playChord(name: String) {
    let chordNotes = ChordNotes(name: name)
    let midiNotes = convertChordNotesToMidi(notes: chordNotes.getNotes())
    createPlayer(chords: [midiNotes])
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
