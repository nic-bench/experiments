#!/bin/bash
source common.sh
if [ ${T1} != "0" ] ; then
    npf-compare "local" --testie ${NICBENCH_EXP_PATH}/nic-occupancy.npf --cluster ${NPF_CLUSTER} --show-full --show-cmd --output graphs/${CARD}/skylake/rule-performance/data/group-1/rule-perf-bench-fwd-${CARD}-rule-based-skylake-st-set-large-queues-1-group-1-ps-1500-table-impact/ --output-columns x perc1 perc25 median perc75 perc99 avg --graph-size 6.5 3.2 --variables "PC=0" "PORTS=0" PC=0 PRIORITY=1 "NFLOWS=10000" THRESH=1000 --config "var_log={NFLOWS}" "var_lim={NFLOWS:16-2000000}" --config n_runs=${NPF_RUNS} var_serie=TABLE "var_names+={NRULES:Total number of rules accross all tables of a ${NICNAME}}" M=11 --variables "TABLE=[1*16]" M=11 --graph-filename tempgraphs/${NICABR}/fig2c/.svg --tags mstep pipeline ${CARD} ${USER} ${NPF_FLAGS} $@
fi
