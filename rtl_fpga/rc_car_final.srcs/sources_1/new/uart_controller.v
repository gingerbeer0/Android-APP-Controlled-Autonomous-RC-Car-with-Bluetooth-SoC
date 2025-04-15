module uart_controller #(parameter NbitRead = 16) (
    input wire clk,                      // 클럭 신호
    input wire rst,                      // 리셋 신호
    input wire rx,                       // UART 수신 핀
    input wire button,                   // 버튼 입력
    output wire tx,                      // UART 송신 핀
    output reg [NbitRead*8-1:0] buffer_read, // 수신된 데이터 버퍼
    output reg [7:0] store_value         // 가장 최근 수신된 데이터
);

    // 내부 신호 정의
    wire [7:0] rx_data;                  // 수신 데이터
    wire ready;                          // 수신 준비 신호
    wire rcv;                            // 수신 완료 신호
    reg [1:0] buffer_ready;              // 송신 준비 상태
    reg [1:0] buffer_button;             // 버튼 입력 디바운싱
    reg start;                           // 송신 시작 신호
    reg [7:0] tx_data;                   // 송신 데이터
    reg [$clog2(NbitRead*8):0] point;    // 송신 데이터 포인터
    reg [NbitRead*8-1:0] buffer_tmp;     // 송신 버퍼 데이터

    // UART 인스턴스
    UART MYUART (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .start(start),
        .tx_data(tx_data),
        .tx(tx),
        .ready(ready),
        .rx_data(rx_data),
        .rcv(rcv)
    );

    // 수신 처리
    always @(posedge rcv or posedge rst) begin
        if (rst) begin
            buffer_read <= {(NbitRead*8){2'b10}}; // 초기화
            store_value <= 8'd1;                 // 초기값 설정
        end else begin
            buffer_read <= {buffer_read[NbitRead*8-8:0], rx_data}; // 데이터 시프트
            store_value <= buffer_read[NbitRead*8-1:NbitRead*8-8]; // 최신 데이터 갱신
        end
    end

    // 송신 상태 및 버튼 디바운싱 처리
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buffer_ready <= 2'b11;
            buffer_button <= 2'b00;
        end else begin
            buffer_ready <= {buffer_ready[0], ready};
            buffer_button <= {buffer_button[0], button};
        end
    end

    // 송신 상태 제어
    localparam IDLE = 2'b00, TRAN = 2'b01, KEEP = 2'b10;
    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            start <= 0;
            state <= IDLE;
            tx_data <= "E";
            point <= NbitRead*8;
            buffer_tmp <= 0;
        end else begin
            case (state)
                IDLE: begin
                    start <= 0;
                    if (buffer_button == 2'b01 && buffer_ready == 2'b11) begin
                        state <= TRAN;
                        tx_data <= buffer_read[NbitRead*8-1:NbitRead*8-8];
                        buffer_tmp <= buffer_read;
                        point <= NbitRead*8;
                    end
                end
                TRAN: begin
                    start <= 1;
                    if (buffer_ready == 2'b10) begin
                        state <= KEEP;
                    end
                end
                KEEP: begin
                    start <= 0;
                    if (buffer_ready == 2'b11) begin
                        if (point == 0) begin
                            state <= IDLE;
                        end else begin
                            state <= TRAN;
                            tx_data <= buffer_tmp[NbitRead*8-1:NbitRead*8-8];
                            buffer_tmp <= buffer_tmp << 8;
                            point <= point - 8;
                        end
                    end
                end
                default: begin
                    state <= IDLE;
                    start <= 0;
                end
            endcase
        end
    end

endmodule
