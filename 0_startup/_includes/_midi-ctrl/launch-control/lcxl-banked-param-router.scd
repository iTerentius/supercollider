/*
  Novation LaunchControl XL Mk2 - Virtual Banking Script
  Author: Music Coding (Gemini)
  Context: Fits into iTerentius sc_system
*/

(
var lcxl = Environment.make({
	// --- Configuration ---
	~midiDeviceName = "Launch Control XL";
	~srcID = nil;

	// --- State ---
	~currentBank = 0; // 0 to 7
	~numBanks = 8;
	// We only need to cache the bank buttons for this script's visuals
	~ledCache = Array.fill(8, { 0 }); 

	// --- Constants from Reference Guide ---
	// SysEx Header: F0 00 20 29 02 11 78 [cite: 91]
	~sysExHeader = Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x11, 0x78];
	
	// Targeting Factory Template 1 (08h) as the base [cite: 92]
	~templateIndex = 0x08; 

	// LED Colors (Decimal values: Green<<4 + Red) [cite: 51]
	~colors = (
		off: 12,
		redLow: 13,
		redFull: 15,
		amberLow: 29,
		amberFull: 63,
		greenLow: 28,
		greenFull: 60
	);

	// Control Indices [cite: 104, 107]
	// Bottom Row (Track Focus) indices for SysEx: 32 - 39 (20h - 27h)
	~bankButtonIndices = (32..39);

	// --- Initialization ---
	~init = {
		var srcIdx;
		MIDIClient.init;

		// Connect only to LCXL, not all devices
		srcIdx = MIDIClient.sources.detectIndex { |s| s.name.contains(~midiDeviceName) };
		if(srcIdx.notNil) {
			MIDIIn.connect(srcIdx);
			["LCXL: MIDIIn connected (index " ++ srcIdx ++ ")"].postln;
		};

		// Find the LCXL Destination
		~midiOut = MIDIOut.newByName("Launch Control XL", "Launch Control XL");
		if(~midiOut.isNil, {
			"LCXL: Device not found!".warn;
		}, {
			"LCXL: Device Connected.".postln;
			~midiOut.latency = 0;
		});

		~srcID = if(srcIdx.notNil) { MIDIClient.sources[srcIdx].uid } { nil };

		// Initialize Responders
		~makeResponders.value; // <--- FIXED: Added .value

		// Refresh UI
		~renderBankLEDs.value;
	};

	// --- SysEx LED Helper ---
	// Updates a specific index with a specific velocity (color)
	~setLED = {|index, velocity|
		var msg;
		// Msg: Header + Template + Index + Value + F7 [cite: 90, 91]
		msg = ~sysExHeader ++ Int8Array[~templateIndex, index, velocity, 0xF7];
		~midiOut.sysex(msg);
	};

	// --- Bank Rendering ---
	~renderBankLEDs = {
		~bankButtonIndices.do({ |buttonIndex, i|
			var color;
			if(i == ~currentBank, {
				color = ~colors[\greenFull]; // Active Bank
			}, {
				color = ~colors[\redLow];   // Inactive Bank
			});
			~setLED.value(buttonIndex, color);
		});
		("LCXL: Switched to Bank " ++ (~currentBank + 1)).postln;
	};

	// --- MIDI Responders ---
	~makeResponders = {
		MIDIFunc.trace(false); 

		// 1. Bank Selectors (Bottom Row Buttons)
		// Factory Template 1 Bottom row usually maps to Notes 41-48 (F1 - C2 range usually)
		// Adjust 'num' check below if your specific template sends different notes.
		MIDIFunc.noteOn({ |vel, num, chan, src|
			var bankIndex;
			// Checking typical Factory 1 mapping for bottom row
			if((num >= 41) && (num <= 48), {
				bankIndex = num - 41;
				~currentBank = bankIndex;
				~renderBankLEDs.value;
			});
		}, srcID: ~srcID);
    
    ~bankIndex = 0;
		// 2. Faders and Knobs (Control Change)
		MIDIFunc.cc({ |val, num, chan, src|
			var trackIndex, virtualCC;

			// Handle Faders (Standard CC 77-84)
			if((num >= 77) && (num <= 84), {
				trackIndex = num - 77;
				virtualCC = (~currentBank * 8) + trackIndex;
				// ACTION: Do something with the virtual fader
				("Fader - Virtual Track: " ++ virtualCC ++ " Value: " ++ val).postln;
			});

			// Handle Knobs Send A (Standard CC 13-20)
			if((num >= 13) && (num <= 20), {
				trackIndex = num - 13;
				virtualCC = (~currentBank * 8) + trackIndex;
				// ACTION: Do something with Knob A
				("Knob A - Virtual Track: " ++ virtualCC ++ " Value: " ++ val).postln;
			});

			// Handle Knobs Send B (Standard CC 29-36)
			if((num >= 29) && (num <= 36), {
				trackIndex = num - 29;
				virtualCC = (~currentBank * 8) + trackIndex;
				// ACTION: Do something with Knob B
				("Knob B - Virtual Track: " ++ virtualCC ++ " Value: " ++ val).postln;
			});

			// Handle Pan Knobs (Standard CC 49-56)
			if((num >= 49) && (num <= 56), {
				trackIndex = num - 49;
				virtualCC = (~currentBank * 8) + trackIndex;
				// ACTION: Do something with Pan Knob
				("Pan - Virtual Track: " ++ virtualCC ++ " Value: " ++ val).postln;
			});

		}, srcID: ~srcID);

    MIDIFunc.noteOn({ |vel, num, chan, src|
        
        // We only want to trigger when the button is PRESSED (velocity > 0).
        // (Otherwise, releasing the button might trigger it again)
        if(vel > 0) {
            
            // Check which note was pressed and set the bank
            switch(num,
                73, { 
                    ~bankIndex = 0; 
                    "Bank 1 Selected".postln; 
                },
                74, { 
                    ~bankIndex = 1; 
                    "Bank 2 Selected".postln; 
                },
                75, { 
                    ~bankIndex = 2; 
                    "Bank 3 Selected".postln; 
                },
                76, { 
                    ~bankIndex = 3; 
                    "Bank 4 Selected".postln; 
                },
                // Add more cases here if you have more buttons (e.g. 89)
                { "Unknown Button: ".post; num.postln; } // Default case
            );

            // Optional: Force an update of your LEDs here if needed
            // ~updateLEDs.value(); 
        };

    }, chan: 8); // Restrict this listener to Channel 8 (MIDI Ch 9)
	};
});

// Run Initialization
lcxl.use({ ~init.value });
)
