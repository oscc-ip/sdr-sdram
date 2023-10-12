.PHONY: sim-verilog sim-launch clean

GUI ?=
MODULES = init aref write read arbit ctrl model
MODULE ?=

ifeq ($(GUI), y)
    GUI_TEMP = -gui
else ifeq ($(GUI),)
    GUI_TEMP =
else ifeq ($(GUI), n)
    GUI_TEMP =
else
    $(error $$GUI is incorrect, optional values are [y] or [n])
endif

ifeq ($(filter $(MODULES), $(MODULE)), )
    ifneq ($(MAKECMDGOALS), clean)
        $(error $$MODULE is incorrect, optional values in [$(MODULES)])
    endif
else
    MODULE_RTL = \
        ../rtl/ctrl/modules/sdram_init.v \
        ../rtl/ctrl/modules/sdram_$(MODULE).v
    MODULE_SIM = ../sim/ctrl/modules/tb_sdram_$(MODULE).v
    ifeq ($(MODULE), ctrl)
        MODULE_RTL = ../rtl/ctrl/sdram_ctrl.v
        MODULE_SIM = ../sim/ctrl/tb_sdram_ctrl.v
    else ifeq ($(MODULE), model)
        MODULE_RTL =
        MODULE_SIM = ../sim/tb_sdram_model.v
    endif
endif

sim-verilog:
	cd models && \
	ncverilog $(GUI_TEMP) +access+r +define+clk_133+x16 W989DxDB.nc.vp \
		$(MODULE_RTL) \
		$(MODULE_SIM)
sim-launch:
	cd models && \
	nclaunch +access+r +define+clk_133+x16 W989DxDB.nc.vp \
		$(MODULE_RTL) \
		$(MODULE_SIM)
clean:
	find ./models -not -name "*.vp" -not -name "*.v" | \
		tail -n +2 | \
		xargs rm -rf
