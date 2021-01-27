#!/bin/bash
source common.sh

if [ "${T1}" != "0" ] ; then
    python3 ~/npf/npf-compare.py "local" --testie ~/workspace/nic-bench-experiments/nic-occupancy.testie --cluster ${NPF_CLUSTER} --show-full --show-cmd --output graphs/mlnx-${NICABR}/skylake/rule-performance/data/group-1/rule-perf-bench-fwd-mlnx-${NICABR}-rule-based-skylake-st-set-large-queues-1-group-1-ps-1500-latency/ --output-columns x perc1 perc25 median perc75 perc99 avg --graph-size 6.5 3.2 --variables "PC=0" "PORTS=0" PC=0 PRIORITY=1 "NFLOWS=10000" THRESH=1000 --config "var_log={NFLOWS}" "var_lim={NFLOWS:16-2000000}" --config n_runs=${NPF_RUNS} var_serie=TABLE "var_names+={NRULES:Total number of rules accross all tables of a ${NICNAME}}" --result-path .results_latency_2d/ --variables "TABLE=1" --tags mstep mlnx-${NICABR}  prate --variables GEN_RATE=5000000 "TABLE={1,16}" GEN_BLOCKING=false --graph-filename tempgraphs/${NICABR}/fig2d/.svg ${NPF_FLAGS} $@
fi
