# List of modules to build
MODULES = counting segment7 clock counting_clock

# Common variables
VERILATOR = verilator
VERILATOR_FLAGS = -Wall --trace --x-assign unique --x-initial unique

# Special flags for specific modules (if needed)
counting_FLAGS = -GCOUNTING_BITS=4 -GMAX=9
segment7_FLAGS = -GSEGMENTS=4

.PHONY: all
all: $(MODULES)

.PHONY: $(MODULES)
$(MODULES): %: %.vcd

.PHONY: sim
sim: $(addsuffix .vcd,$(MODULES))

.PHONY: verilate
verilate: $(addprefix .stamp.verilate.,$(MODULES))

.PHONY: build
build: $(addprefix obj_dir/V,$(MODULES))

.PHONY: waves
waves: %.vcd
	@echo
	@echo "### WAVES ###"
	gtkwave $<

%.vcd: ./obj_dir/V%
	@echo
	@echo "### SIMULATING $* ###"
	./$<

./obj_dir/V%: .stamp.verilate.%
	@echo
	@echo "### BUILDING SIM $* ###"
	make -C obj_dir -f V$*.mk V$*

.stamp.verilate.%: %.sv tb_%.cpp
	@echo
	@echo "### VERILATING $* ###"
	$(VERILATOR) $(VERILATOR_FLAGS) $($*_FLAGS) -cc $*.sv --exe tb_$*.cpp
	@touch $@

.PHONY: lint
lint: $(addsuffix .sv,$(MODULES))
	for module in $(MODULES); do \
		$(VERILATOR) --lint-only $$module.sv; \
	done

.PHONY: clean
clean:
	rm -rf .stamp.*
	rm -rf ./obj_dir
	rm -rf *.vcd

# Individual module targets
.PHONY: $(addsuffix _sim,$(MODULES))
$(addsuffix _sim,$(MODULES)): %_sim: %.vcd

.PHONY: $(addsuffix _verilate,$(MODULES))
$(addsuffix _verilate,$(MODULES)): %_verilate: .stamp.verilate.%

.PHONY: $(addsuffix _build,$(MODULES))
$(addsuffix _build,$(MODULES)): %_build: obj_dir/V%

.PHONY: $(addsuffix _waves,$(MODULES))
$(addsuffix _waves,$(MODULES)): %_waves: %.vcd
	gtkwave $<