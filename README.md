# Verilog-HDL-Calculator

### top 모듈 Idea 소개

자료의 입력, 저장, 시작, 완료에 대한 신호를 flag로 선언하여, 특정 flag가 1이 되었을때 어떤 동작을 수행하고, 다시 flag를 0으로만들어 동작을 종류하는 형태로 설계. 탑 모듈의 F/F의 idea는

**1) variable 선언부 :**
입출력으로 clk, rst, key_io, seg_data,seg_com이 있으며, 각각을 수정할 시 클럭과 FND구현에 버그가 생길수있으므로 수정하지않는다.

*필요시, wire와 reg형으로 새롭게 변수를 생성한다.*

**2) clk,key_padmodule 관련호출부 :**
클럭 속도 변경을 위해 clk_wizard와 clk_PLL을 사용하고, 키패드 사용을 위한instance, 키패드 입력 시 생기는 클럭 노이즈를 잡는 debounce가 있다. 이 또한 수정 시 버그가 생길 수 있으므로 수정하지않는다.

**3) key_pulse 입력F/F회로 :**
리셋 버튼이 눌렸을때, 기존 A값을 초기화하고, key_pulse가 9 이하일때(즉,연산자가아닐때) key_pulse를 A[0]에저장하며, 이미 저장된 A[n]은 A[n+1]로 Shift된다.

**4) dec7module 호출부 :**
instance는 assign문처럼 concurrent하게 작동하므로, 동시에 2개의 데이터가 dec_out으로 출력되지 않게하기위해 수정에 유의한다. A를 input으로하여, 그것을 FND에 표시할 수 있는 비트로 출력한다.

**5) seg_com관련F/F회로,이하always문 :**
seg_com은 FND가 적은 핀으로도 작동하는 상태를 눈으로 볼 수 있도록 낮은 클럭을 사용하여 F/F을작성한다. FND 관련 회로는 수정할 필요가 없다고 생각했다.

*각각의자리수5번~0번의타이밍에맞춰저장된dec_out을출력한다.*
```verilog
input rst,
inout [7:0] key_io, // input, output
output [7:0] seg_data,
output [5:0] seg_com
wire [23:0] data_output;
wire clk_6mhz, clk_1khz, flag_out, flag_inf_out, flag_ovf_out;
wire [4:0] key_tmp, key, key_pulse;
reg [54:0] data, data_input;
reg [3:0] A[0:5 ];
wire [6:0] dec_out[0:5];
reg ok, clean, start, flag_in, flag_ovf_in, flag_inf_in;
reg [5:0] seg_com;
reg [7:0] seg_data;
```
먼저 사용된 variable은 위와 같다.

```verilog
always @(posedge clk_6mhz, posedge rst) begin
  if (rst == 1 || key_pulse[3:0]==4'hF) begin
    A[0] <= 4'hF; A[1] <= 4'hF;
    A[2] <= 4'hF; A[3] <= 4'hF;
    A[4] <= 4'hF; A[5] <= 4'hF;
    ok <= 1'b0; clean <= 1'b0;
    start <= 1'b0; flag_in <= flag_out;
    flag_inf_in <=flag_inf_out; flag_ovf_in <=flag_ovf_out;
  end
//continue...
```
TOP모듈의 F/F회로에서, rst와 F버튼은 역할을 공유하므로, 이미 FND에 표시되고 있는 A값과 모든 플래그를 초기화시키는 분장으로 설계
![image](https://user-images.githubusercontent.com/80473250/166288581-cbbfb08c-41d9-4367-af1c-3bea8d665db1.png)

입력한 key_pulse를 A에 저장하는 code는 수정 없이 그대로 사용한다. 특별한 조건이 없을 때 숫자를 입력하면 최대 6자리까지 숫자를 A에 저장할 수 있으며 연산자 (key_pulse[3:0] > 9)인 경우, A값은 4-bit 55개의 변수명(data) 중 24번째부터 47번째까지에 저장한다. 그리고 ok_flag를 1로 만든다. ok_flag는 두번째 숫자를 받을 준비가 되었다는 뜻이며, 이후 숫자를 입력하고 E(=)를 누를 때, 첫번째 숫자를 저장했는지 검사를 돕는다.

```verilog
else if(key_pulse[4] == 1 && key_pulse[3:0] == 4'hE&& ok == 1);
```
여기에, clean <== 1'b1에서 clean == 1이 되면 아래와 같은 문장을 수행한다.
```verilog
else if(clean == 1) begin
  A[0] <= 4'hF A[1] <= 4'hF;
  A[2] <= 4'hF; A[3] <= 4'hF;
  A[4] <= 4'hF; A[5] <= 4'hF;
  clean<=1'b0;
end
```
