// Verilator Example
// Norbertas Kremeris 2021
#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vsegment7.h"

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

int main(int argc, char** argv, char** env) {
    srand (time(NULL));
    Verilated::commandArgs(argc, argv);
    Vsegment7 *dut = new Vsegment7;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("segment7.vcd");

    dut->counter = 0;
    dut->enable = 1;
    dut->decimal_point = 4;
    dut->digit_enable = 7;
    dut->digit[0] = 6;
    dut->digit[1] = 7;
    dut->digit[2] = 8;
    dut->digit[3] = 9;

    while (sim_time < MAX_SIM_TIME) {
        dut->counter = sim_time % 4;
        dut->eval();

        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
