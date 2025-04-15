module fire_detector (
    input wire clk,            // 클럭 입력
    input wire rst,            // 리셋 신호 (비동기)
    input wire fire_sensor, // 광저항 신호 (불꽃 감지)
    output reg led_front       // LED 출력 (불꽃 감지 시 켜짐)
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_front <= 0; 
        end else if (fire_sensor) begin
            led_front <= 1; 
        end else begin
            led_front <= 0;
        end
    end
endmodule
