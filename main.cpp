// For std::unique_ptr
#include <memory>

// Include common routines
#include <verilated.h>

#include "Vcpu.h"  // Replace with your top-level module's header
#include "Vcpu_cpu.h"  // Replace with your top-level module's header

int main(int argc, char** argv, char** env) {
        // This is a more complicated example, please also see the simpler examples/make_hello_c.

    // Prevent unused variable warnings
    if (false && argc && argv) {}

    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");

    // Construct a VerilatedContext to hold simulation time, etc.
    // Multiple modules (made later below with Vtop) may share the same
    // context to share time, or modules may have different contexts if
    // they should be independent from each other.

    // Using unique_ptr is similar to
    // "VerilatedContext* contextp = new VerilatedContext" then deleting at end.
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    // Do not instead make Vtop as a file-scope static variable, as the
    // "C++ static initialization order fiasco" may cause a crash

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    contextp->randReset(2);

    // Verilator must compute traced signals
    contextp->traceEverOn(true);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);

    // Construct the Verilated model, from Vtop.h generated from Verilating "top.v".
    // Using unique_ptr is similar to "Vtop* top = new Vtop" then deleting at end.
    // "TOP" will be the hierarchical name of the module.
    const std::unique_ptr<Vcpu> top{new Vcpu{contextp.get(), "cpu"}};

    // Set Vtop's input signals
    top->reset_n = 0;
    top->clock = 0;
    top->csr_ctl = 0x0;
            
            
    top->r1 = 1;
    top->r2 = 2;
    top->r3 = 3;
    top->r4 = 4;
    top->r5 = 5;


    // Simulate until $finish
    while (!contextp->gotFinish()){
            if(contextp->time() > 2000)
            break;
        // Historical note, before Verilator 4.200 Verilated::gotFinish()
        // was used above in place of contextp->gotFinish().
        // Most of the contextp-> calls can use Verilated:: calls instead;
        // the Verilated:: versions just assume there's a single context
        // being used (per thread).  It's faster and clearer to use the
        // newer contextp-> versions.

        contextp->timeInc(1);  // 1 timeprecision period passes...
        // Historical note, before Verilator 4.200 a sc_time_stamp()
        // function was required instead of using timeInc.  Once timeInc()
        // is called (with non-zero), the Verilated libraries assume the
        // new API, and sc_time_stamp() will no longer work.

        // Toggle a fast (time/2 period) clock
        top->clock = !top->clock;

        // Toggle control signals on an edge that doesn't correspond
        // to where the controls are sampled; in this example we do
        // this only on a negedge of clk, because we know
        // reset is not sampled there.
        if (top->clock){ 
            if (contextp->time() >= 0 && contextp->time() < 100) {
                top->reset_n = 0;  // Assert reset
                top->csr_ctl = 0x0;
            } else {
                top->reset_n = 1;  // Deassert reset
                top->csr_ctl = 0x1;
            }

            // Assign some other inputs
            //top->r2 = 0;
            //top->r3 = 0;
            //top->r4 = 0;
    // Coverage analysis (calling write only after the test is known to pass)
            //top->r5 = 0;
        }

        // Evaluate model
        // (If you have multiple models being simulated in the same
        // timestep then instead of eval(), call eval_step() on each, then
        // eval_end_step() on each. See the manual.)
        top->eval();

        // Read outputs
        VL_PRINTF("[%" PRId64 "] state: %x clk=%x rstl=%x csr_ctrl=%x csr_status=%x r0=%" PRIx64 " r1=%" PRIx64 " r2=%" PRIx64 " r3=%" PRIx64 " r4=%" PRIx64 " r5=%" PRIx64 " r6=%" PRIx64 " r7=%" PRIx64 " r8=%" PRIx64 " r9=%" PRIx64 " r10=%" PRIx64 " address=%" PRIx64 " instr=%" PRIx64 "\n",
                  contextp->time(), top->cpu->state, top->clock, top->reset_n, top->csr_ctl, top->csr_status, top->r0, top->cpu->regs1, top->cpu->regs2, top->cpu->regs3, top->cpu->regs4, top->cpu->regs5, top->r6, top->r7, top->r8, top->r9, top->r10, top->cpu->ip, top->cpu->instruction);

        if(top->cpu->instruction == 0x9500000000000000)
            break;

    }


    // Final model cleanup
//    top->final();

    // Return good completion status
    // Don't use exit() or destructor won't get called
    return 0;
}
