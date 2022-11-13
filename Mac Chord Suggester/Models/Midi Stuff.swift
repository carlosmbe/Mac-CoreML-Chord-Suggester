//
//  Midi Stuff.swift
//  Mac Chord Suggester
//
//  Created by Carlos Mbendera on 13/11/2022.
//


import AudioToolbox
import Foundation


struct ChordNotes{
    
    let name: String
    let containsAccidental: Bool

    var root_name: String
    var quality_name: String
        
    init(name: String) {
        self.name = name
        
        var containsAccidentalComputed : Bool{
            let nameArray = Array(name)
            if nameArray.count > 2 && (nameArray[1] == "#" || nameArray[1] == "b"){
                return true
            }else {return false}
        }
        
        self.containsAccidental = containsAccidentalComputed
        self.root_name = containsAccidental ? String(name.prefix(2)) : String(name.prefix(1))
        let qualityCount = Array(name).count - (containsAccidental ? 2 : 1)
        self.quality_name =  containsAccidental ? String(name.suffix(qualityCount)) : String(name.suffix(qualityCount))
        
    }
    
    func getNotes() -> [String]{
        let root_value = ToNumber[root_name] as! Int
        let quality_components = ToComponents[quality_name] as! [Int]
        
        let absolute_quality_components = quality_components.map{ relative_component in
            root_value + relative_component
        }
        
        let accidentalToAvoid = root_name.contains("b") ? "#" : "b"

        let baseScale = (root_value >= 7) ? 3 : 4;

        let notes = absolute_quality_components.map{component in
            let suffix = baseScale + (component / NumberOfNotes)
           
            let noteNameIndex = "\(component % NumberOfNotes)"
            let noteNameArray = ToNote[noteNameIndex] as! [String]
            
            var note_name : String {
                for note in noteNameArray{
                    if !note.contains(accidentalToAvoid){
                       // print("Value is \(note)")
                        return note
                    }
                }
                fatalError("NO Notes with accidental to avoid")
            }
              
          //  print("OG LINe = \(note_name)")
         
            
           return "\(note_name)\(suffix)"
        }
        return notes
    }
    
}

func covertChordNotesToMidi(notes: [String]) -> [UInt8]{
    var midiNotes = [UInt8]()
    for var note in notes{
        note.removeLast()
        let baseNumber = ToNumber[note] as! UInt8
        print(baseNumber + 60)
        midiNotes.append(baseNumber + 60)
    }

    return midiNotes
}

func createMusicSequence(chords: [[UInt8]] ) -> MusicSequence {
    // create the sequence
    var musicSequence: MusicSequence?
    var status = NewMusicSequence(&musicSequence)
    if status != noErr {
        print(" bad status \(status) creating sequence")
    }
    
    var tempoTrack: MusicTrack?
    if MusicSequenceGetTempoTrack(musicSequence!, &tempoTrack) != noErr {
        assert(tempoTrack != nil, "Cannot get tempo track")
    }
    //MusicTrackClear(tempoTrack, 0, 1)
    if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, 128.0) != noErr {
        print("could not set tempo")
    }
    if MusicTrackNewExtendedTempoEvent(tempoTrack!, 4.0, 256.0) != noErr {
        print("could not set tempo")
    }
    
    
    // add a track
    var track: MusicTrack?
    status = MusicSequenceNewTrack(musicSequence!, &track)
    if status != noErr {
        print("error creating track \(status)")
    }
    
  
    
    // now make some notes and put them on the track
    var beat: MusicTimeStamp = 0.0
   
    for batch in 0..<chords.count {
        for note: UInt8 in chords[batch] {
            var mess = MIDINoteMessage(channel: 0,
                                       note: note,
                                       velocity: 64,
                                       releaseVelocity: 0,
                                       duration: 1.0 )
            status = MusicTrackNewMIDINoteEvent(track!, beat, &mess)
            if status != noErr {    print("creating new midi note event \(status)") }
            
        }// beat changes after this
        beat += 1
    }
    
    CAShow(UnsafeMutablePointer<MusicSequence>(musicSequence!))
    
    return musicSequence!
}

func createPlayer(chords : [[UInt8]]){
    var musicPlayer : MusicPlayer? = nil
    var player = NewMusicPlayer(&musicPlayer)

    player = MusicPlayerSetSequence(musicPlayer!, createMusicSequence(chords: chords))
    player = MusicPlayerStart(musicPlayer!)
}
