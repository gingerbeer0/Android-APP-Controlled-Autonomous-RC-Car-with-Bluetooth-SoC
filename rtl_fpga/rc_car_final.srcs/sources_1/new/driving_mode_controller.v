module driving_mode_controller (
    input wire clk,                      // 클럭 신호
    input wire rst,                      // 리셋 신호
    input wire [7:0] store_value,        // UART로부터 받은 값
    input wire track_sensor_left,        // 왼쪽 트래킹 센서
    input wire track_sensor_right,       // 오른쪽 트래킹 센서
    input wire sound_detected,           // 소리 감지 신호
    output reg [7:0] speed_left_a,       // 왼쪽 모터 전진 속도
    output reg [7:0] speed_left_b,       // 왼쪽 모터 후진 속도
    output reg [7:0] speed_right_a,      // 오른쪽 모터 전진 속도
    output reg [7:0] speed_right_b,      // 오른쪽 모터 후진 속도
    output reg led_left,                 // 좌회전 LED
    output reg led_right                 // 우회전 LED
);
    // 디바운싱 타이머
    reg [31:0] debounce_timer;
    reg last_left_sensor, last_right_sensor;

    // 상태 정의
    localparam STRAIGHT   = 3'b000;
    localparam TURN_LEFT  = 3'b001;
    localparam TURN_RIGHT = 3'b010;
    localparam REVERSE    = 3'b011;
    localparam STOP       = 3'b100;

    // 디바운싱 시간 (클럭 기준)
    localparam DEBOUNCE_TIME = 32'd360000;

    reg [2:0] state;        // 현재 상태
    reg sound_to_stop;      // 소리 기반 정지 신호
    reg manual_mode;        // 수동 모드
    reg sound_detect;

    // 초기화
    initial begin
        state = STRAIGHT;
        speed_left_a = 8'd230;
        speed_left_b = 8'd0;
        speed_right_a = 8'd255;
        speed_right_b = 8'd0;
        debounce_timer = 0;
        manual_mode = 1;
        last_left_sensor = 0;
        last_right_sensor = 0;
        led_left = 0;
        led_right = 0;
        sound_to_stop = 0;
    end

    // 소리 감지 및 정지 처리
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sound_to_stop <= 0;
        end else if (sound_detected) begin
            sound_to_stop <= ~sound_to_stop;
        end
    end

    // 수동 모드 처리
    always @(posedge  clk or posedge  rst) begin
        if (rst) begin
        manual_mode <= 1;
        sound_detect <= 0;
        end else begin
                case(store_value)
                "a": begin
                manual_mode <= 0;
                sound_detect <= 0;
                end
                "m": begin
                manual_mode <= 1;
                sound_detect <= 0;
                end
                "k": begin
                sound_detect <= 1;
                end
                
            endcase
        end
    end

    // 운전 모드 로직
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 리셋 시 초기화
            state <= STRAIGHT;
            speed_left_a <= 8'd230;
            speed_left_b <= 8'd0;
            speed_right_a <= 8'd255;
            speed_right_b <= 8'd0;
            debounce_timer <= 0;
            last_left_sensor <= track_sensor_left;
            last_right_sensor <= track_sensor_right;
            led_left <= 0;
            led_right <= 0;
        end else if (sound_to_stop && sound_detect) begin
            // 소리 감지 시 정지
            state <= STOP;
            speed_left_a <= 8'd0;
            speed_left_b <= 8'd0;
            speed_right_a <= 8'd0;
            speed_right_b <= 8'd0;
            led_left <= 0;
            led_right <= 0;
        end else if (manual_mode) begin
            // 수동 모드 동작
            case (store_value)
                "u": begin
                    state <= STRAIGHT;
                    speed_left_a <= 8'd230;
                    speed_left_b <= 8'd0;
                    speed_right_a <= 8'd230;
                    speed_right_b <= 8'd0;
                    led_left <= 0;
                    led_right <= 0;
                end
                "l": begin
                    state <= TURN_LEFT;
                    speed_left_a <= 8'd0;
                    speed_left_b <= 8'd0;
                    speed_right_a <= 8'd230;
                    speed_right_b <= 8'd0;
                    led_left <= 1;
                    led_right <= 0;
                end
                "r": begin
                    state <= TURN_RIGHT;
                    speed_left_a <= 8'd230;
                    speed_left_b <= 8'd0;
                    speed_right_a <= 8'd0;
                    speed_right_b <= 8'd0;
                    led_left <= 0;
                    led_right <= 1;
                end
                "d": begin
                    state <= REVERSE;
                    speed_left_a <= 8'd0;
                    speed_left_b <= 8'd230;
                    speed_right_a <= 8'd0;
                    speed_right_b <= 8'd230;
                    led_left <= 0;
                    led_right <= 0;
                end
                "s": begin
                    state <= STOP;
                    speed_left_a <= 8'd0;
                    speed_left_b <= 8'd0;
                    speed_right_a <= 8'd0;
                    speed_right_b <= 8'd0;
                    led_left <= 0;
                    led_right <= 0;
                end
                default: begin
                    state <= STOP;
                    speed_left_a <= 8'd0;
                    speed_left_b <= 8'd0;
                    speed_right_a <= 8'd0;
                    speed_right_b <= 8'd0;
                    led_left <= 0;
                    led_right <= 0;
                end
            endcase
        end else begin
            // 자율주행 모드 동작
            if (track_sensor_left != last_left_sensor || track_sensor_right != last_right_sensor) begin
                debounce_timer <= debounce_timer + 1;
            end else begin
                debounce_timer <= 0;
            end

            if (debounce_timer >= DEBOUNCE_TIME) begin
                last_left_sensor <= track_sensor_left;
                last_right_sensor <= track_sensor_right;

                if (track_sensor_left == track_sensor_right) begin
                    state <= STRAIGHT;
                    speed_left_a <= 8'd240;
                    speed_left_b <= 8'd0;
                    speed_right_a <= 8'd255;
                    speed_right_b <= 8'd0;
                    led_left <= 0;
                    led_right <= 0;
                end else if (track_sensor_left == 1) begin
                    state <= TURN_LEFT;
                    speed_left_a <= 8'd0;
                    speed_left_b <= 8'd0;
                    speed_right_a <= 8'd245;
                    speed_right_b <= 8'd0;
                    led_left <= 1;
                    led_right <= 0;
                end else if (track_sensor_right == 1) begin
                    state <= TURN_RIGHT;
                    speed_left_a <= 8'd230;
                    speed_left_b <= 8'd0;
                    speed_right_a <= 8'd0;
                    speed_right_b <= 8'd0;
                    led_left <= 0;
                    led_right <= 1;
                end
            end
        end
    end
endmodule
