module music_controller (
    input wire clk,
    input wire rst,
    input wire [7:0] store_value,
    output reg buzzer
);
    // music
// Define note frequencies (12MHz clock cycles per period)
parameter NOTE_D5  = 20408;  // 12MHz / 587Hz
parameter NOTE_D6  = 10204;  // 12MHz / 1175Hz
parameter NOTE_A5  = 13636;  // 12MHz / 880Hz
parameter NOTE_G5  = 15306;  // 12MHz / 784Hz
parameter NOTE_G6  = 7653;   // 12MHz / 1568Hz
parameter NOTE_FS6 = 8108;   // 12MHz / 1480Hz
parameter NOTE_E5  = 18182;  // 12MHz / 659Hz
parameter NOTE_E6  = 9091;   // 12MHz / 1318Hz
parameter NOTE_E4  = 36364;  // 12MHz / 329Hz
parameter NOTE_G4  = 30612;  // 12MHz / 392Hz
parameter NOTE_A4  = 27273;  // 12MHz / 440Hz
parameter NOTE_B4  = 24390;  // 12MHz / 494Hz
parameter NOTE_B5  = 12195;  // 12MHz / 988Hz
parameter NOTE_C5  = 22900;  // 12MHz / 523Hz
parameter NOTE_C6  = 11450;  // 12MHz / 1046Hz
parameter NOTE_AS4 = 25751;  // 12MHz / 466Hz
parameter NOTE_AS5 = 12825;  // 12MHz / 932Hz
parameter NOTE_FS5 = 17163;  // 12MHz / 698Hz
parameter NOTE_F5  = 18182;  // 12MHz / 659Hz
parameter NOTE_F6  = 9091;   // 12MHz / 1318Hz
parameter NOTE_A6  = 6818;   // 12MHz / 1760Hz
parameter REST     = 0;      // Silence


// Song melodies and durations (32 notes each)
reg [15:0] melody1 [0:31];
reg [23:0] durations1 [0:31];

reg [15:0] melody2 [0:31];
reg [23:0] durations2 [0:31];

reg [15:0] melody3 [0:31];
reg [23:0] durations3 [0:31];

            reg [15:0] selected_melody [0:31];
            reg [23:0] selected_durations [0:31];

// Playback state
reg play = 0;  // 1: Play melody, 0: Stop melody
reg [1:0] selected_song = 0;  // 0: No song, 1: Song 1, 2: Song 2, 3: Song 3

// State variables
reg [15:0] current_note = 0;   // Current note index
reg [23:0] note_counter = 0;  // Counter for note duration
reg [15:0] tone_counter = 0;  // Counter for tone generation

// Initialize melodies and durations
initial begin
    // Song 1
    melody1[0]  = NOTE_D5;  durations1[0]  = 3000000;
    melody1[1]  = NOTE_D6;  durations1[1]  = 3000000;
    melody1[2]  = NOTE_A5;  durations1[2]  = 3000000;
    melody1[3]  = NOTE_G5;  durations1[3]  = 3000000;
    melody1[4]  = NOTE_G6;  durations1[4]  = 3000000;
    melody1[5]  = NOTE_A5;  durations1[5]  = 3000000;
    melody1[6]  = NOTE_FS6; durations1[6]  = 3000000;
    melody1[7]  = NOTE_A5;  durations1[7]  = 3000000;
    melody1[8]  = NOTE_D5;  durations1[8]  = 3000000;
    melody1[9]  = NOTE_D6;  durations1[9]  = 3000000;
    melody1[10] = NOTE_A5;  durations1[10] = 3000000;
    melody1[11] = NOTE_G5;  durations1[11] = 3000000;
    melody1[12] = NOTE_G6;  durations1[12] = 3000000;
    melody1[13] = NOTE_A5;  durations1[13] = 3000000;
    melody1[14] = NOTE_FS6; durations1[14] = 3000000;
    melody1[15] = NOTE_A5;  durations1[15] = 3000000;
    melody1[16] = NOTE_E5;  durations1[16] = 3000000;
    melody1[17] = NOTE_D6;  durations1[17] = 3000000;
    melody1[18] = NOTE_A5;  durations1[18] = 3000000;
    melody1[19] = NOTE_G5;  durations1[19] = 3000000;
    melody1[20] = NOTE_G6;  durations1[20] = 3000000;
    melody1[21] = NOTE_A5;  durations1[21] = 3000000;
    melody1[22] = NOTE_FS6; durations1[22] = 3000000;
    melody1[23] = NOTE_A5;  durations1[23] = 3000000;
    melody1[24] = NOTE_E5;  durations1[24] = 3000000;
    melody1[25] = NOTE_D6;  durations1[25] = 3000000;
    melody1[26] = NOTE_A5;  durations1[26] = 3000000;
    melody1[27] = NOTE_G5;  durations1[27] = 3000000;
    melody1[28] = NOTE_G6;  durations1[28] = 3000000;
    melody1[29] = NOTE_A5;  durations1[29] = 3000000;
    melody1[30] = NOTE_FS6; durations1[30] = 3000000;
    melody1[31] = NOTE_A5;  durations1[31] = 3000000;
    
// Song 2 (12MHz 기준 지속 시간, 한 옥타브 올림 및 지속 시간 2배 증가)
melody2[0]  = NOTE_E5;  durations2[0]  = 1500000; 
melody2[1]  = NOTE_G5;  durations2[1]  = 1500000; 
melody2[2]  = NOTE_A5;  durations2[2]  = 3000000; 
melody2[3]  = NOTE_A5;  durations2[3]  = 1500000; 
melody2[4]  = NOTE_A5;  durations2[4]  = 1500000; 
melody2[5]  = NOTE_B5;  durations2[5]  = 1500000; 
melody2[6]  = NOTE_C6;  durations2[6]  = 1500000; 
melody2[7]  = NOTE_C6;  durations2[7]  = 3000000; 
melody2[8]  = NOTE_C6;  durations2[8]  = 1500000; 
melody2[9]  = NOTE_D6;  durations2[9]  = 1500000; 
melody2[10] = NOTE_B5;  durations2[10] = 1500000; 
melody2[11] = NOTE_B5;  durations2[11] = 1500000; 
melody2[12] = NOTE_A5;  durations2[12] = 3000000; 
melody2[13] = NOTE_G5;  durations2[13] = 1500000; 
melody2[14] = NOTE_A5;  durations2[14] = 1500000; 
melody2[15] = NOTE_E5;  durations2[15] = 1500000; 
melody2[16] = NOTE_G5;  durations2[16] = 1500000; 
melody2[17] = NOTE_A5;  durations2[17] = 3000000; 
melody2[18] = NOTE_A5;  durations2[18] = 1500000; 
melody2[19] = NOTE_B5;  durations2[19] = 1500000; 
melody2[20] = NOTE_C6;  durations2[20] = 1500000; 
melody2[21] = NOTE_C6;  durations2[21] = 3000000; 
melody2[22] = NOTE_D6;  durations2[22] = 1500000; 
melody2[23] = NOTE_D6;  durations2[23] = 1500000; 
melody2[24] = NOTE_E6;  durations2[24] = 1500000; 
melody2[25] = NOTE_F6;  durations2[25] = 1500000; 
melody2[26] = NOTE_F6;  durations2[26] = 3000000; 
melody2[27] = NOTE_D6;  durations2[27] = 1500000; 
melody2[28] = NOTE_E6;  durations2[28] = 1500000; 
melody2[29] = NOTE_C6;  durations2[29] = 1500000; 
melody2[30] = NOTE_B5;  durations2[30] = 1500000; 
melody2[31] = NOTE_A5;  durations2[31] = 3000000;


// Song 3 (12MHz 기준 지속 시간, 한 옥타브 올림 및 지속 시간 2배 증가)
melody3[0]  = NOTE_E6;  durations3[0]  = 1500000; 
melody3[1]  = NOTE_E6;  durations3[1]  = 1500000; 
melody3[2]  = REST;     durations3[2]  = 1500000; 
melody3[3]  = NOTE_E6;  durations3[3]  = 1500000; 
melody3[4]  = REST;     durations3[4]  = 1500000; 
melody3[5]  = NOTE_C6;  durations3[5]  = 1500000; 
melody3[6]  = NOTE_E6;  durations3[6]  = 1500000; 
melody3[7]  = NOTE_G6;  durations3[7]  = 3000000; 
melody3[8]  = REST;     durations3[8]  = 3000000; 
melody3[9]  = NOTE_G5;  durations3[9]  = 1500000; 
melody3[10] = REST;     durations3[10] = 3000000; 
melody3[11] = NOTE_C6;  durations3[11] = 3000000; 
melody3[12] = NOTE_A5;  durations3[12] = 1500000; 
melody3[13] = NOTE_B5;  durations3[13] = 3000000; 
melody3[14] = NOTE_AS5; durations3[14] = 3000000; 
melody3[15] = NOTE_A5;  durations3[15] = 3000000; 
melody3[16] = NOTE_G5;  durations3[16] = 3000000; 
melody3[17] = NOTE_E6;  durations3[17] = 1500000; 
melody3[18] = NOTE_G6;  durations3[18] = 3000000; 
melody3[19] = NOTE_A6;  durations3[19] = 1500000; 
melody3[20] = NOTE_F6;  durations3[20] = 1500000; 
melody3[21] = NOTE_G6;  durations3[21] = 1500000; 
melody3[22] = REST;     durations3[22] = 3000000; 
melody3[23] = NOTE_E6;  durations3[23] = 1500000; 
melody3[24] = NOTE_C6;  durations3[24] = 1500000; 
melody3[25] = NOTE_D6;  durations3[25] = 1500000; 
melody3[26] = NOTE_B5;  durations3[26] = 3000000; 
melody3[27] = REST;     durations3[27] = 1500000; 
melody3[28] = NOTE_E6;  durations3[28] = 1500000; 
melody3[29] = NOTE_C6;  durations3[29] = 3000000; 
melody3[30] = NOTE_G5;  durations3[30] = 3000000; 
melody3[31] = REST;     durations3[31] = 1500000; 

end

integer i;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset state
        current_note <= 0;
        note_counter <= 0;
        tone_counter <= 0;
        play <= 0;
        buzzer <= 0;
        selected_song <= 0;
    end else begin
        // Control playback based on store_value
        case (store_value)
            "1": begin
                selected_song <= 1;  // Play Song 1
                play <= 1;

                // Copy melody1 and durations1
                for (i = 0; i < 32; i = i + 1) begin
                    selected_melody[i] = melody1[i];
                    selected_durations[i] = durations1[i];
                end
            end
            "2": begin
                selected_song <= 2;  // Play Song 2
                play <= 1;

                // Copy melody2 and durations2
                for (i = 0; i < 32; i = i + 1) begin
                    selected_melody[i] = melody2[i];
                    selected_durations[i] = durations2[i];
                end
            end
            "3": begin
                selected_song <= 3;  // Play Song 3
                play <= 1;

                // Copy melody3 and durations3
                for (i = 0; i < 32; i = i + 1) begin
                    selected_melody[i] = melody3[i];
                    selected_durations[i] = durations3[i];
                end
            end
            "4": begin
                play <= 0;  // Stop playback
            end
            default: begin
                selected_song <= 0;  // No song selected
                play <= 0;  // Stop playback
            end
        endcase

        if (play) begin
            // Play the selected melody
            if (note_counter < selected_durations[current_note]) begin
                note_counter <= note_counter + 1;

                // Generate tone
                if (selected_melody[current_note] != REST) begin
                    if (tone_counter < selected_melody[current_note]) begin
                        tone_counter <= tone_counter + 1;
                    end else begin
                        tone_counter <= 0;
                        buzzer <= ~buzzer;  // Toggle buzzer output
                    end
                end else begin
                    buzzer <= 0;  // Silence
                end
            end else begin
                // Move to the next note
                note_counter <= 0;
                tone_counter <= 0;
                current_note <= current_note + 1;

                // Loop melody
                if (current_note == 31)
                    current_note <= 0;
            end
        end else begin
            // If not playing, set buzzer to 0
            buzzer <= 0;
            note_counter <= 0;
            tone_counter <= 0;
            current_note <= 0;
        end
    end
end

endmodule
