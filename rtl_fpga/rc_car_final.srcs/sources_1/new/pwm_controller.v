module pwm_controller (
    input wire clk,
    input wire rst,
    input wire [7:0] speed_left_a,
    input wire [7:0] speed_left_b,
    input wire [7:0] speed_right_a,
    input wire [7:0] speed_right_b,
    output reg pwm_left_a,
    output reg pwm_left_b,
    output reg pwm_right_a,
    output reg pwm_right_b
);
    reg [7:0] pwm_counter;

    always @(posedge clk or posedge rst) begin
        if (rst || pwm_counter == 8'd255) begin
            pwm_counter <= 0;
            pwm_left_a <= 0;
            pwm_left_b <= 0;
            pwm_right_a <= 0;
            pwm_right_b <= 0;
        end else begin
            pwm_counter <= pwm_counter + 1;
            pwm_left_a <= (pwm_counter < speed_left_a) ? 0 : 1;
            pwm_left_b <= (pwm_counter < speed_left_b) ? 0 : 1;
            pwm_right_a <= (pwm_counter < speed_right_a) ? 0 : 1;
            pwm_right_b <= (pwm_counter < speed_right_b) ? 0 : 1;
        end
    end
endmodule
