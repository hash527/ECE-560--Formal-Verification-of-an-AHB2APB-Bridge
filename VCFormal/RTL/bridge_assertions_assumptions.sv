// AHB to APB Bridge - Formal Verification Assertions
// Date: 01-31-2025
// For use with VC Formal (Synopsys Formal Verification)

module bridge_formal_properties;

// Import the design signals - bind statement will connect these
logic Hclk, Hresetn, Hwrite, Hreadyin;
logic [31:0] Hwdata, Haddr, Prdata;
logic [1:0] Htrans;
logic Penable, Pwrite, Hreadyout;
logic [1:0] Hresp;
logic [2:0] Pselx;
logic [31:0] Paddr, Pwdata, Hrdata;
logic valid;
logic [31:0] Haddr1, Haddr2;
logic Hwritereg;
logic [2:0] tempselx;

// FSM state type - must match your APB_FSM_Controller
typedef enum bit[3:0] { 
    ST_IDLE, ST_WWAIT, ST_READ, ST_WRITE, 
    ST_WRITEP, ST_RENABLE, ST_WENABLE, ST_WENABLEP
} STATE;

STATE fsm_state;

//=============================================================================
// ASSUMPTIONS - Input Constraints for Formal Verification
//=============================================================================

// ASSUMPTION 1: Htrans valid values (00=IDLE, 10=NONSEQ, 11=SEQ)
// No BUSY transfers allowed
property assume_htrans_valid;
    @(posedge Hclk) Htrans inside {2'b00, 2'b10, 2'b11};
endproperty
assume_htrans_range: assume property(assume_htrans_valid);

// ASSUMPTION 2: Reset behavior - Hresetn goes high and stays high after reset
property assume_hresetn_eventually_high;
    @(posedge Hclk) !Hresetn |-> ##[1:3] Hresetn;
endproperty
assume_reset_behavior: assume property(assume_hresetn_eventually_high);

// ASSUMPTION 3: Valid address range for bridge (0x8000_0000 to 0x8C00_0000)
property assume_haddr_range;
    @(posedge Hclk) 
        (Htrans != 2'b00) |-> (Haddr >= 32'h8000_0000 && Haddr < 32'h8C00_0000);
endproperty
assume_address_range: assume property(assume_haddr_range);

// ASSUMPTION 4: Htrans = 10 (NONSEQ) in first cycle of transaction
property assume_htrans_first_cycle;
    @(posedge Hclk) disable iff(!Hresetn)
        ($past(Htrans) == 2'b00 && Htrans != 2'b00) |-> (Htrans == 2'b10);
endproperty
assume_nonseq_start: assume property(assume_htrans_first_cycle);

// ASSUMPTION 5: Htrans = 00 (IDLE) in second cycle of single transaction
property assume_htrans_second_cycle;
    @(posedge Hclk) disable iff(!Hresetn)
        ($past(Htrans) == 2'b10 && $past(Htrans, 2) == 2'b00) |-> (Htrans == 2'b00);
endproperty
assume_idle_after_nonseq: assume property(assume_htrans_second_cycle);

//=============================================================================
// ASSERTION 1: PSELx must be one-hot (only one select active at a time)
//=============================================================================
property assert_pselx_onehot;
    @(posedge Hclk) disable iff(!Hresetn)
        $onehot0(Pselx); // One-hot or zero
endproperty
assert_pselx_onehot_encoding: assert property(assert_pselx_onehot);

//=============================================================================
// ASSERTION 2: Valid signal generation
//=============================================================================
property assert_valid_generation;
    @(posedge Hclk) disable iff(!Hresetn)
        (Hreadyin && 
         (Haddr >= 32'h8000_0000 && Haddr < 32'h8C00_0000) && 
         (Htrans == 2'b10 || Htrans == 2'b11)) |=> valid;
endproperty
assert_valid_signal: assert property(assert_valid_generation);

//=============================================================================
// ASSERTION 3-5: Peripheral Select Logic (tempselx)
//=============================================================================
// ASSERTION 3: PSELX = 001 for address range 8000_0000 to 8400_0000
property assert_tempselx_slave1;
    @(posedge Hclk) disable iff(!Hresetn)
        (Haddr >= 32'h8000_0000 && Haddr < 32'h8400_0000) |=> (tempselx == 3'b001);
endproperty
assert_select_slave1: assert property(assert_tempselx_slave1);

// ASSERTION 4: PSELX = 010 for address range 8400_0000 to 8800_0000
property assert_tempselx_slave2;
    @(posedge Hclk) disable iff(!Hresetn)
        (Haddr >= 32'h8400_0000 && Haddr < 32'h8800_0000) |=> (tempselx == 3'b010);
endproperty
assert_select_slave2: assert property(assert_tempselx_slave2);

// ASSERTION 5: PSELX = 100 for address range 8800_0000 to 8C00_0000
property assert_tempselx_slave3;
    @(posedge Hclk) disable iff(!Hresetn)
        (Haddr >= 32'h8800_0000 && Haddr < 32'h8C00_0000) |=> (tempselx == 3'b100);
endproperty
assert_select_slave3: assert property(assert_tempselx_slave3);

//=============================================================================
// ASSERTION 6-7: AHB Response Signals
//=============================================================================
// ASSERTION 6: Hrdata equals Prdata in same cycle
property assert_hrdata_equals_prdata;
    @(posedge Hclk) Hrdata == Prdata;
endproperty
assert_read_data_passthrough: assert property(assert_hrdata_equals_prdata);

// ASSERTION 7: Hresp should always be OKAY (2'b00)
property assert_hresp_okay;
    @(posedge Hclk) Hresp == 2'b00;
endproperty
assert_response_always_okay: assert property(assert_hresp_okay);

//=============================================================================
// ASSERTION 8-10: FSM State ST_IDLE Outputs
//=============================================================================
// ASSERTION 8: ST_IDLE with valid==0
property assert_idle_no_valid;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_IDLE && !valid) |=> 
        (Pselx == 3'b000 && Penable == 0 && Hreadyout == 1);
endproperty
assert_idle_outputs: assert property(assert_idle_no_valid);

// ASSERTION 9: ST_IDLE with valid==1 and read (Hwrite==0)
property assert_idle_to_read;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_IDLE && valid && !Hwrite) |=>
        (Paddr == $past(Haddr) && Pwrite == 0 && 
         Pselx == $past(tempselx) && Penable == 0 && Hreadyout == 0);
endproperty
assert_idle_read_setup: assert property(assert_idle_to_read);

// ASSERTION 10: ST_IDLE with valid==1 and write (Hwrite==1)
property assert_idle_to_wwait;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_IDLE && valid && Hwrite) |=>
        (Penable == 0 && Pselx == 3'b000 && Hreadyout == 1);
endproperty
assert_idle_write_setup: assert property(assert_idle_to_wwait);

//=============================================================================
// ASSERTION 11-12: FSM State ST_WWAIT Outputs
//=============================================================================
// ASSERTION 11: ST_WWAIT with valid==0
property assert_wwait_no_valid;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_WWAIT && !valid) |=>
        (Paddr == $past(Haddr1) && Pwrite == 1 && 
         Pselx == $past(tempselx) && Penable == 0 && 
         Pwdata == $past(Hwdata) && Hreadyout == 0);
endproperty
assert_wwait_to_write: assert property(assert_wwait_no_valid);

// ASSERTION 12: ST_WWAIT with valid==1
property assert_wwait_with_valid;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_WWAIT && valid) |=>
        (Paddr == $past(Haddr1) && Pwrite == 1 && 
         Pselx == $past(tempselx) && Pwdata == $past(Hwdata) && 
         Penable == 0 && Hreadyout == 0);
endproperty
assert_wwait_to_writep: assert property(assert_wwait_with_valid);

//=============================================================================
// ASSERTION 13: FSM State ST_READ Outputs
//=============================================================================
property assert_read_outputs;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_READ) |=> (Penable == 1 && Hreadyout == 1);
endproperty
assert_read_phase: assert property(assert_read_outputs);

//=============================================================================
// ASSERTION 14: FSM States ST_WRITE and ST_WRITEP Outputs
//=============================================================================
property assert_write_outputs;
    @(posedge Hclk) disable iff(!Hresetn)
        ((fsm_state == ST_WRITE) || (fsm_state == ST_WRITEP)) |=>
        (Penable == 1 && Hreadyout == 1);
endproperty
assert_write_phase: assert property(assert_write_outputs);

//=============================================================================
// ASSERTION 15: FSM State ST_RENABLE with valid==0
//=============================================================================
property assert_renable_no_valid;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_RENABLE && !valid) |=>
        (Pselx == 3'b000 && Penable == 0 && Hreadyout == 1);
endproperty
assert_renable_idle: assert property(assert_renable_no_valid);

//=============================================================================
// ASSERTIONS 16-30: FSM State Transitions
//=============================================================================

// ASSERTION 16: ST_IDLE → ST_READ when valid && !Hwrite
property assert_idle_to_read_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_IDLE && valid && !Hwrite) |=> (fsm_state == ST_READ);
endproperty
assert_transition_idle_read: assert property(assert_idle_to_read_transition);

// ASSERTION 17: ST_IDLE → ST_WWAIT when valid && Hwrite
property assert_idle_to_wwait_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_IDLE && valid && Hwrite) |=> (fsm_state == ST_WWAIT);
endproperty
assert_transition_idle_wwait: assert property(assert_idle_to_wwait_transition);

// ASSERTION 18: ST_WWAIT → ST_WRITE when !valid
property assert_wwait_to_write_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_WWAIT && !valid) |=> (fsm_state == ST_WRITE);
endproperty
assert_transition_wwait_write: assert property(assert_wwait_to_write_transition);

// ASSERTION 19: ST_WWAIT → ST_WRITEP when valid
property assert_wwait_to_writep_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_WWAIT && valid) |=> (fsm_state == ST_WRITEP);
endproperty
assert_transition_wwait_writep: assert property(assert_wwait_to_writep_transition);

// ASSERTION 20: ST_READ → ST_RENABLE (always)
property assert_read_to_renable_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_READ) |=> (fsm_state == ST_RENABLE);
endproperty
assert_transition_read_renable: assert property(assert_read_to_renable_transition);

// ASSERTION 21: ST_WRITE → ST_WENABLE when !valid
property assert_write_to_wenable_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_WRITE && !valid) |=> (fsm_state == ST_WENABLE);
endproperty
assert_transition_write_wenable: assert property(assert_write_to_wenable_transition);

// ASSERTION 22: ST_WRITE → ST_WENABLEP when valid
property assert_write_to_wenablep_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_WRITE && valid) |=> (fsm_state == ST_WENABLEP);
endproperty
assert_transition_write_wenablep: assert property(assert_write_to_wenablep_transition);

// ASSERTION 23: ST_WRITEP → ST_WENABLEP (always)
property assert_writep_to_wenablep_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_WRITEP) |=> (fsm_state == ST_WENABLEP);
endproperty
assert_transition_writep_wenablep: assert property(assert_writep_to_wenablep_transition);

// ASSERTION 24: ST_RENABLE → ST_IDLE when !valid
property assert_renable_to_idle_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_RENABLE && !valid) |=> (fsm_state == ST_IDLE);
endproperty
assert_transition_renable_idle: assert property(assert_renable_to_idle_transition);

// ASSERTION 25: ST_RENABLE → ST_WWAIT when valid && Hwrite
property assert_renable_to_wwait_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_RENABLE && valid && Hwrite) |=> (fsm_state == ST_WWAIT);
endproperty
assert_transition_renable_wwait: assert property(assert_renable_to_wwait_transition);

// ASSERTION 26: ST_RENABLE → ST_READ when valid && !Hwrite
property assert_renable_to_read_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_RENABLE && valid && !Hwrite) |=> (fsm_state == ST_READ);
endproperty
assert_transition_renable_read: assert property(assert_renable_to_read_transition);

// ASSERTION 27: ST_WENABLE → ST_IDLE when !valid && Hwritereg
property assert_wenable_to_idle_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_WENABLE && !valid && Hwritereg) |=> (fsm_state == ST_IDLE);
endproperty
assert_transition_wenable_idle: assert property(assert_wenable_to_idle_transition);

// ASSERTION 28: ST_WENABLEP → ST_WRITE when !valid && Hwritereg
property assert_wenablep_to_write_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_WENABLEP && !valid && Hwritereg) |=> (fsm_state == ST_WRITE);
endproperty
assert_transition_wenablep_write: assert property(assert_wenablep_to_write_transition);

// ASSERTION 29: ST_WENABLEP → ST_WRITEP when valid && Hwritereg
property assert_wenablep_to_writep_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_WENABLEP && valid && Hwritereg) |=> (fsm_state == ST_WRITEP);
endproperty
assert_transition_wenablep_writep: assert property(assert_wenablep_to_writep_transition);

// ASSERTION 30: ST_WENABLEP → ST_READ when !Hwritereg
property assert_wenablep_to_read_transition;
    @(posedge Hclk) disable iff(!Hresetn)
        (fsm_state == ST_WENABLEP && !Hwritereg) |=> (fsm_state == ST_READ);
endproperty
assert_transition_wenablep_read: assert property(assert_wenablep_to_read_transition);

//=============================================================================
// ASSERTION 31: FSM Valid States Only
//=============================================================================
property assert_valid_states;
    @(posedge Hclk) disable iff(!Hresetn)
        fsm_state inside {ST_IDLE, ST_WWAIT, ST_READ, ST_WRITE, 
                         ST_WRITEP, ST_RENABLE, ST_WENABLE, ST_WENABLEP};
endproperty
assert_fsm_valid_states: assert property(assert_valid_states);

//=============================================================================
// ASSERTION 32: Penable Protocol Compliance
//=============================================================================
property assert_penable_transfer_phase;
    @(posedge Hclk) disable iff(!Hresetn)
        (Penable == 1) |-> (fsm_state inside {ST_READ, ST_WRITE, ST_WRITEP, 
                                               ST_RENABLE, ST_WENABLE, ST_WENABLEP});
endproperty
assert_penable_protocol: assert property(assert_penable_transfer_phase);

//=============================================================================
// ASSERTION 33: Hreadyout Behavior
//=============================================================================
property assert_hreadyout_low_during_transfer_start;
    @(posedge Hclk) disable iff(!Hresetn)
        ((fsm_state == ST_IDLE && valid && !Hwrite) ||
         (fsm_state == ST_WWAIT)) |=> (Hreadyout == 0);
endproperty
assert_hreadyout_timing: assert property(assert_hreadyout_low_during_transfer_start);

endmodule
