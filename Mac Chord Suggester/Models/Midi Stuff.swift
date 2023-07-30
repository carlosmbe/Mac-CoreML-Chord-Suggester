//
//  Midi Stuff.swift
//  Mac Chord Suggester
//
//  Created by Carlos Mbendera on 13/11/2022.
//
import AudioToolbox

struct ChordNotes {
    let name: String
    let containsAccidental: Bool
    var rootName: String
    var qualityName: String
        
    init(name: String) {
        self.name = name
        self.containsAccidental = Array(name)[1] == "#" || Array(name)[1] == "b"
        self.rootName = containsAccidental ? String(name.prefix(2)) : String(name.prefix(1))
        let qualityCount = name.count - (containsAccidental ? 2 : 1)
        self.qualityName = String(name.suffix(qualityCount))
    }
    
    func getNotes() -> [String] {
        let rootValue = ToNumber[rootName] as! Int
        let qualityComponents = ToComponents[qualityName] as! [Int]
        let absoluteQualityComponents = qualityComponents.map { rootValue + $0 }
        let accidentalToAvoid = rootName.contains("b") ? "#" : "b"
        let baseScale = (rootValue >= 7) ? 3 : 4

        return absoluteQualityComponents.compactMap { component in
            let suffix = baseScale + (component / NumberOfNotes)
            let noteNameIndex = "\(component % NumberOfNotes)"
            let noteNameArray = ToNote[noteNameIndex] as! [String]
            let noteName = noteNameArray.first { !$0.contains(accidentalToAvoid) } ?? ""
            return "\(noteName)\(suffix)"
        }
    }
}

func convertChordNotesToMidi(notes: [String]) -> [UInt8] {
    return notes.compactMap { note in
        var mutableNote = note
        mutableNote.removeLast()
        return ToNumber[mutableNote] as? UInt8
    }.map { $0 + 60 }
}

func createMusicSequence(chords: [[UInt8]]) -> MusicSequence {
    var musicSequence: MusicSequence?
    NewMusicSequence(&musicSequence)
    
    var track: MusicTrack?
    MusicSequenceNewTrack(musicSequence!, &track)
    
    var beat: MusicTimeStamp = 0.0
    
    for chord in chords {
        for note in chord {
            var mess = MIDINoteMessage(channel: 0, note: note, velocity: 64, releaseVelocity: 0, duration: 1.0)
            MusicTrackNewMIDINoteEvent(track!, beat, &mess)
        }
        beat += 1
    }
    
    CAShow(UnsafeMutablePointer<MusicSequence>(musicSequence!))
    
    return musicSequence!
}

func createPlayer(chords: [[UInt8]]) {
    var musicPlayer: MusicPlayer? = nil
    NewMusicPlayer(&musicPlayer)
    MusicPlayerSetSequence(musicPlayer!, createMusicSequence(chords: chords))
    MusicPlayerStart(musicPlayer!)
}
