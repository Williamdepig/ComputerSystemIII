DIR_REPO		?= $(CURDIR)/../../repo
DIR_PATCH		?= $(CURDIR)/../../patch
DIR_UPSTREAM	?= $(DIR_REPO)/sys-3-project
DIR_BUILD		?= $(CURDIR)/build

DIR_SYN			?= $(DIR_UPSTREAM)/syn
DIR_TCL			?= $(DIR_UPSTREAM)/tcl
DIR_SIM			?= $(DIR_UPSTREAM)/sim
DIR_COSIM_IP	?= $(DIR_UPSTREAM)/ip
DIR_INCLUDE		?= $(DIR_UPSTREAM)/include
DIR_GENERAL		?= $(DIR_UPSTREAM)/general
CUSTOM_INCLUDE  ?= $(CURDIR)/include
DIR_SRC			?= $(CURDIR)/submit
SIM_BUILD		?= $(DIR_BUILD)/verilate

DIR_TEST		?= $(DIR_UPSTREAM)/testcode
DIR_TESTCASE	?= $(DIR_TEST)/testcase

# part for verilator
VERILATOR_TOP		:= Testbench
VERILATOR_SRCS		=  $(shell find $(DIR_SIM) -name "*.v" -o -name "*.sv" -o -name "*.cpp") \
					   $(shell find $(DIR_SRC) -name "*.v" -o -name "*.sv") \
					   $(shell find $(DIR_GENERAL) -name "*v" -o -name "*.sv")

VERILATOR_TFLAGS	:= -Wno-STMTDLY --timescale 1ns/10ps --trace
VERILATOR_FLAGS		:= --cc --exe  --main --timing\
						--Mdir $(SIM_BUILD) --top-module $(VERILATOR_TOP) \
						-o $(VERILATOR_TOP) -I$(DIR_INCLUDE) -I$(CUSTOM_INCLUDE)\
						-CFLAGS "-DVL_DEBUG -DTOP=${VERILATOR_TOP} -std=c++17 \
						-iquote$(DIR_COSIM_IP)/include/riscv -iquote$(DIR_COSIM_IP)/include/cosim -iquote$(DIR_COSIM_IP)/include/fesvr" \
						-LDFLAGS "-L$(DIR_COSIM_IP)/lib  -l:libcosim.a -l:libriscv.a -l:libdisasm.a -l:libsoftfloat.a -l:libfdt.a -l:libfesvr.a"
VERILATOR_DEFINE	:= +define+TOP_DIR=\"$(SIM_BUILD)\" +define+VERILATE

TESTCASE ?= sample

verilate:$(VERILATOR_TOP)
	make -C $(DIR_TEST)
	cp $(DIR_TEST)/testcase.elf $(SIM_BUILD)/testcase.elf
	cp $(DIR_TEST)/rom/rom.hex $(SIM_BUILD)/rom.hex
	cp $(DIR_TEST)/dummy/dummy.hex $(SIM_BUILD)/elf.hex
	cp $(DIR_TEST)/mini_sbi.hex $(SIM_BUILD)/mini_sbi.hex
	cd $(SIM_BUILD); ./$(VERILATOR_TOP)

verilate_sort:$(VERILATOR_TOP)
	make -C $(DIR_TEST)/sort
	cp $(DIR_TEST)/sort/testcase.elf $(SIM_BUILD)/testcase.elf
	cp $(DIR_TEST)/rom/rom.hex $(SIM_BUILD)/rom.hex
	cp $(DIR_TEST)/dummy/dummy.hex $(SIM_BUILD)/elf.hex
	cp $(DIR_TEST)/sort/sort.hex $(SIM_BUILD)/mini_sbi.hex
	cd $(SIM_BUILD); ./$(VERILATOR_TOP)

board_sim:$(VERILATOR_TOP)
	make -C $(DIR_TEST) board
	cp $(DIR_TEST)/bootload/bootload.elf $(SIM_BUILD)/testcase.elf
	cp $(DIR_TEST)/bootload/bootload.hex $(SIM_BUILD)/rom.hex
	cp $(DIR_TEST)/elf.hex $(SIM_BUILD)/elf.hex
	cp $(DIR_TEST)/dummy/dummy.hex $(SIM_BUILD)/mini_sbi.hex
	cd $(SIM_BUILD); ./$(VERILATOR_TOP)

verilate_testcase:$(VERILATOR_TOP)
	make -C $(DIR_TESTCASE) gen
	cp $(DIR_TESTCASE)/$(TESTCASE)/*.elf $(SIM_BUILD)/testcase.elf
	cp $(DIR_TESTCASE)/$(TESTCASE)/*.hex $(SIM_BUILD)/testcase.hex
	cd $(SIM_BUILD); ./$(VERILATOR_TOP)

board_sim_testcase:$(VERILATOR_TOP) 
	make -C $(DIR_TESTCASE) board
	cp $(DIR_TESTCASE)/$(TESTCASE)/*.elf $(SIM_BUILD)/testcase.elf
	cp $(DIR_TESTCASE)/$(TESTCASE)/*.hex $(SIM_BUILD)/testcase.hex
	cd $(SIM_BUILD); ./$(VERILATOR_TOP)
	

$(VERILATOR_TOP):$(VERILATOR_SRCS) $(DIR_COSIM_IP)
	mkdir -p $(SIM_BUILD)
	verilator $(VERILATOR_TFLAGS) $(VERILATOR_FLAGS) $(VERILATOR_SRCS) $(VERILATOR_DEFINE)
	make -C $(SIM_BUILD) -f V$(VERILATOR_TOP).mk $(VERILATOR_TOP)

wave:
	gtkwave $(SIM_BUILD)/$(VERILATOR_TOP).vcd

clean_verilate:
	rm -rf $(SIM_BUILD)

# part for vivado
# Replace with your own path, for example:
#   If your Vivado is installed in Windows:   
#   	 VIVADO_SETUP := call D:\App\Xilinx\Vivado\2022.2\settings64.bat
#   or in Linux: 
#        VIVADO_SETUP := source /opt/Xilinx/Vivado/2022.2/settings64.sh
VIVADO_SETUP		:=  call D:\software\Vivado\Vivado\2022.2\settings64.bat

CMD_PREFIX			:=	bash -c
PATH_TRANS			:=	realpath
DIR_PROJECT			?= $(DIR_BUILD)/project
BOARD				?=	xc7a100tcsg324-1
TOP_MODULE			?=	top 

ifneq (,$(findstring microsoft,$(shell uname -a)))
WSLENV				:=	$(WSLENV):DIR_SRC/p:DIR_SYN/p:DIR_TCL/p:DIR_BUILD/p:DIR_INCLUDE/p:CUSTOM_INCLUDE/p:DIR_GENERAL/p
DIR_PROJECT			:=	/mnt/d/software/git/vivadobit/sys3/sys3-lab2
CMD_PREFIX			:=	cmd.exe /c
PATH_TRANS			:=	wslpath -w
endif

export DIR_SRC DIR_SYN DIR_TCL DIR_PROJECT DIR_INCLUDE DIR_GENERAL CUSTOM_INCLUDE

bitstream:
	mkdir -p $(DIR_PROJECT)
	cd $(DIR_PROJECT); cp $(DIR_TCL)/vivado.tcl .; $(CMD_PREFIX) "$(VIVADO_SETUP) && set DIR_SRC && \
		vivado -mode batch -nojournal -source vivado.tcl -tclargs -top-module $(TOP_MODULE) -board $(BOARD)"

vivado:
	mkdir -p $(DIR_PROJECT)
	cd $(DIR_PROJECT); $(CMD_PREFIX) "$(VIVADO_SETUP) && vivado"

clean_vivado:
	rm -rf $(DIR_PROJECT)

clean:clean_verilate
	make -C $(DIR_TEST) clean
