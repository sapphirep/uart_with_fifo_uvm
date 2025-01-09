class uart_top_vseq_base extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(uart_top_vseq_base)

    uart_top_vsequencer vsqr;
    uart_top_sequencer  agt1_sqr;
    uart_top_sequencer  agt2_sqr;

    function new (string name = "uart_top_vseq_base");
        super.new(name);
    endfunction

    virtual task body();
        if (!uvm_resource_db #(uart_top_vsequencer)::read_by_name("vsqr::*", "vsqr", vsqr, this))
            `uvm_fatal("VSEQ BASE", "Failed to retrieve virtual sequencer handle!")

        agt1_sqr = vsqr.agt1_sqr;
        agt2_sqr = vsqr.agt2_sqr;
    endtask

endclass: uart_top_vseq_base


class uart_vseq_half_duplex extends uart_top_vseq_base;
    `uvm_object_utils(uart_vseq_half_duplex)

    uart_write_seq wr_seq = uart_write_seq::type_id::create("wr_seq");
    uart_read_seq  rd_seq = uart_read_seq::type_id::create("rd_seq");
    
    function new (string name = "uart_vseq_half_duplex");
        super.new(name);
    endfunction

    virtual task body();
        super.body();

        repeat (20) begin
            // ===================================
            // Writes on Agent 1, reads on Agent 2
            // ===================================
            wr_seq.randomize();
            rd_seq.randomize();

            `uvm_info("VSEQ_HD", $sformatf("Executing writes for %2d times on Agent 1 sequencer...", wr_seq.iteraions), UVM_LOW)
            wr_seq.start(agt1_sqr);

            // Wait for TX to complete
            #10ms;

            `uvm_info("VSEQ_HD", $sformatf("Executing reads for %2d times on Agent 2 sequencer...", rd_seq.iteraions), UVM_LOW)
            rd_seq.start(agt2_sqr);

            // ===================================
            // Writes on Agent 2, reads on Agent 1
            // ===================================
            wr_seq.randomize();
            rd_seq.randomize();

            `uvm_info("VSEQ_HD", $sformatf("Executing writes for %2d times on Agent 2 sequencer...", wr_seq.iteraions), UVM_LOW)
            wr_seq.start(agt2_sqr);

            // Wait for TX to complete
            #10ms;

            `uvm_info("VSEQ_HD", $sformatf("Executing reads for %2d times on Agent 1 sequencer...", rd_seq.iteraions), UVM_LOW)
            rd_seq.start(agt1_sqr);
        end

    endtask

endclass: uart_vseq_half_duplex


class uart_vseq_full_duplex extends uart_top_vseq_base;
    `uvm_object_utils(uart_vseq_full_duplex)

    uart_write_seq wr_seq1 = uart_write_seq::type_id::create("wr_seq1");
    uart_read_seq  rd_seq1 = uart_read_seq::type_id::create("rd_seq1");

    uart_write_seq wr_seq2 = uart_write_seq::type_id::create("wr_seq2");
    uart_read_seq  rd_seq2 = uart_read_seq::type_id::create("rd_seq2");

    function new (string name = "uart_vseq_full_duplex");
        super.new(name);
    endfunction

    virtual task body();
        super.body();

        repeat (20) begin
            wr_seq1.randomize();
            wr_seq2.randomize();
            fork
                begin
                    `uvm_info("VSEQ_FD", $sformatf("Executing writes for %2d times on Agent 1 sequencer...", wr_seq1.iteraions), UVM_LOW)
                    wr_seq1.start(agt1_sqr);
                end

                begin
                    `uvm_info("VSEQ_FD", $sformatf("Executing writes for %2d times on Agent 2 sequencer...", wr_seq2.iteraions), UVM_LOW)
                    wr_seq2.start(agt2_sqr);
                end
            join

            // Wait for TX to complete
            #10ms;

            rd_seq1.randomize();
            rd_seq2.randomize();
            fork
                begin
                    `uvm_info("VSEQ_FD", $sformatf("Executing reads for %2d times on Agent 1 sequencer...", rd_seq1.iteraions), UVM_LOW)
                    rd_seq1.start(agt1_sqr);
                end

                begin
                    `uvm_info("VSEQ_FD", $sformatf("Executing reads for %2d times on Agent 2 sequencer...", rd_seq2.iteraions), UVM_LOW)
                    rd_seq2.start(agt2_sqr);
                end
            join
        end

    endtask

endclass: uart_vseq_full_duplex