module calc(data_input, data_output, flag_out, flag_inf_out, flag_ovf_out) ;
    input [54:0] data_input;
    output flag_out;
    output [23:0] data_output;
    output reg flag_inf_out, flag_ovf_out;
    
    
    wire[23:0] data1, data2;
    reg [20:0] result_CAL;
    wire[3:0] result[5:0], data_in[11:0], data[11:0], CAL;
    wire flag_inf_in, flag_ovf_in, flag_in;
    
    assign flag_in = data_input[52];
    assign flag_inf_in = data_input[53];
    assign flag_ovf_in = data_input[54];
    
    assign flag_out = (flag_in == 1)? 0 : 1;
    
    assign CAL = data_input[51:48];
    
    assign data_in[11] = data_input[47:44]+1;
    assign data_in[10] = data_input[43:40]+1;
    assign data_in[9] = data_input[39:36]+1;
    assign data_in[8] = data_input[35:32]+1;
    assign data_in[7] = data_input[31:28]+1;
    assign data_in[6] = data_input[27:24]+1;
    assign data_in[5] = data_input[23:20]+1;
    assign data_in[4] = data_input[19:16]+1;
    assign data_in[3] = data_input[15:12]+1;
    assign data_in[2] = data_input[11:8]+1;
    assign data_in[1] = data_input[7:4]+1;
    assign data_in[0] = data_input[3:0]+1;
    
    assign data1 = (data[11]*100000) + (data[10]*10000) + (data[9]*1000) + (data[8]*100) + (data[7]*10) + (data[6]);
    assign data2 = (data[5]*100000) + (data[4]*10000) + (data[3]*1000) + (data[2]*100) + (data[1]*10) + (data[0]);
    
    assign data[11] = (data_in[11]==0)? data_in[11] : data_in[11]-1;
    assign data[10] = (data_in[10]==0)? data_in[10] : data_in[10]-1;
    assign data[9] = (data_in[9]==0)? data_in[9] : data_in[9]-1;
    assign data[8] = (data_in[8]==0)? data_in[8] : data_in[8]-1;
    assign data[7] = (data_in[7]==0)? data_in[7] : data_in[7]-1;
    assign data[6] = (data_in[6]==0)? data_in[6] : data_in[6]-1;
    assign data[5] = (data_in[5]==0)? data_in[5] : data_in[5]-1;
    assign data[4] = (data_in[4]==0)? data_in[4] : data_in[4]-1;
    assign data[3] = (data_in[3]==0)? data_in[3] : data_in[3]-1;
    assign data[2] = (data_in[2]==0)? data_in[2] : data_in[2]-1;
    assign data[1] = (data_in[1]==0)? data_in[1] : data_in[1]-1;
    assign data[0] = (data_in[0]==0)? data_in[0] : data_in[0]-1;
    
    assign result[5] = (result_CAL[19:0]/100000);
    assign result[4] = (result_CAL[19:0]/10000) - (result[5]*10);
    assign result[3] = (result_CAL[19:0]/1000) - (result[5]*100) - (result[4]*10);
    assign result[2] = (result_CAL[19:0]/100) - (result[5]*1000) - (result[4]*100) - (result[3]*10);
    assign result[1] = (result_CAL[19:0]/10) - (result[5]*10000) - (result[4]*1000) - (result[3]*100) - (result[2]*10);
    assign result[0] = (result_CAL[19:0]) - (result[5]*100000) - (result[4]*10000) - (result[3]*1000) - (result[2]*100) - (result[1]*10);
    
    assign data_output[23:20] = (result[5]==0)? 4'hF : result[5];
    assign data_output[19:16] = (result[5]==0 && result[4]==0)? 4'hF : result[4];
    assign data_output[15:12] = (result[5]==0 && result[4]==0 && result[3]==0)? 4'hF : result[3];
    assign data_output[11:8] = (result[5]==0 && result[4]==0 && result[3]==0 && result[2]==0)? 4'hF : result[2];
    assign data_output[7:4] = (result[5]==0 && result[4]==0 && result[3]==0 && result[2]==0 && result[1]==0)? 4'hF : result[1];
    assign data_output[3:0] = result[0];
    
    
    always@ (*) begin
        flag_inf_out = flag_inf_in;
        flag_ovf_out = flag_ovf_in;
        if(data2 != 0) begin 
            case(CAL)
                4'hD : result_CAL = data1 + data2;
                4'hC : result_CAL = data1 - data2;
                4'hB : result_CAL = data1 * data2;
                4'hA : result_CAL = data1 / data2;
                default : result_CAL  = 0;
            endcase
            if(result_CAL > 999999) begin 
                flag_ovf_out = (flag_ovf_in == 1)? 0 : 1;
            end
        end
        else if(data2 == 0) begin
            case(CAL)
                4'hD : result_CAL = data1 + data2;
                4'hC : result_CAL = data1 - data2;
                4'hB : result_CAL = data1 * data2;
                4'hA : flag_inf_out = (flag_inf_in == 1)? 0 : 1;
                default : result_CAL = 0;
            endcase
            if(result_CAL > 999999) begin 
                flag_ovf_out = (flag_ovf_in == 1)? 0 : 1;
            end
        end
    end
endmodule
