module top_rc_car (
    input wire clk,
    input wire rst,
    input wire rx,
    input wire button,
    input wire track_sensor_left,
    input wire track_sensor_right,
    input wire sound_detected,
    input wire fire_sensor,
    output wire tx,
    output wire pwm_left_a,
    output wire pwm_left_b,
    output wire pwm_right_a,
    output wire pwm_right_b,
    output wire led_left,
    output wire led_right,
    output wire led_front,
    output wire buzzer
);
    wire [7:0] store_value;
    wire [127:0] buffer_read;
	wire [7:0] speed_left_a;      // 왼쪽 모터 전진 속도
    wire [7:0] speed_left_b;      // 왼쪽 모터 후진 속도
    wire [7:0] speed_right_a;     // 오른쪽 모터 전진 속도
    wire [7:0] speed_right_b;     // 오른쪽 모터 후진 속도

    // UART
    uart_controller uart_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .button(button),
        .tx(tx),
        .buffer_read(buffer_read),
        .store_value(store_value)
    );

    // PWM
    pwm_controller pwm_inst (
        .clk(clk),
        .rst(rst),
        .speed_left_a(speed_left_a),
        .speed_left_b(speed_left_b),
        .speed_right_a(speed_right_a),
        .speed_right_b(speed_right_b),
        .pwm_left_a(pwm_left_a),
        .pwm_left_b(pwm_left_b),
        .pwm_right_a(pwm_right_a),
        .pwm_right_b(pwm_right_b)
    );

    // Driving Mode Controller (속도 계산 및 LED 제어)
    driving_mode_controller drive_inst (
        .clk(clk),
        .rst(rst),
        .store_value(store_value),
        .track_sensor_left(track_sensor_left),
        .track_sensor_right(track_sensor_right),
        .sound_detected(sound_detected),      
        .speed_left_a(speed_left_a),  // 계산된 속도를 출력으로 연결
        .speed_left_b(speed_left_b),
        .speed_right_a(speed_right_a),
        .speed_right_b(speed_right_b),
        .led_left(led_left),
        .led_right(led_right)
    );

    // Music Controller
    music_controller music_inst (
        .clk(clk),
        .rst(rst),
        .store_value(store_value),
        .buzzer(buzzer)
    );

	// Fire Detector
    fire_detector fire_inst (
        .clk(clk),
        .rst(rst),
        .fire_sensor(fire_sensor),
        .led_front(led_front)
    );

endmodule
