SRC1_ORI=$(wildcard ./problem1/*.v)
SRC2_ORI=$(wildcard ./problem2/*.v)
tb1=tb1.v
tb2=tb2.v

SRC1=$(filter-out $(tb1), $(SRC1_ORI))
SRC2=$(filter-out $(tb2), $(SRC2_ORI))
PROBLEM1_SRCs=${SRC1} ${tb1}
PROBLEM2_SRCs=${SRC1} ${SRC2} ${tb2}
WAVE=project.vcd
VLOGARG=+access+r
VLOG=xmverilog

sim1:
	${VLOG} ${PROBLEM1_SRCs} ${VLOGARG}
sim2:
	${VLOG} ${PROBLEM2_SRCs} ${VLOGARG}
wave:
	nWave ${WAVE} &
clean:
	rm -rf *.vcd *.fsdb *.log *.history novas* nWaveLog/ vfastLog/ xcelium.d BSSLib.lib++