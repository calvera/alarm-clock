#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vinteger_divider.h"

#define MAX_SIM_TIME 300

int main(int argc, char** argv, char** env) {
    srand (time(NULL));
    Verilated::commandArgs(argc, argv);
    Vinteger_divider *dut = new Vinteger_divider;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("integer_divider.vcd");
    vluint64_t sim_time = 0;

    while (sim_time < MAX_SIM_TIME) {
        dut->clk_in ^= 1;
        dut->eval();

        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
