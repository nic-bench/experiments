#!/bin/bash
source common.sh
python3 ~/npf/npf-compare.py "local" --testie ~/workspace/nic-bench-experiments/nic-occupancy.testie --cluster ${NPF_CLUSTER} --show-full --show-cmd --output graphs/mlnx-${NICABR}/skylake/rule-performance/data/group-0/rule-perf-bench-fwd-mlnx-${NICABR}-rule-based-skylake-st-set-large-queues-1-group-0-ps-1500-cnt-no-flows-impact-new/ --output-columns x perc1 perc25 median perc75 perc99 avg --graph-size 6.5 3.2 --variables "PC=0" "PORTS=0" PC=0 PRIORITY=1 "NFLOWS=10000" THRESH=1000 --config "var_log={NFLOWS}" "var_lim={NFLOWS:16-2000000}" --config "var_lim={result:0-}" n_runs=${NPF_RUNS} --tags small mlnx-${NICABR} --variables TABLE=0 --config "var_names+={NRULES:# of rules in Table 0 of a 100 GbE ${NICNAME}}" --graph-filename tempgraphs/${NICABR}/fig2a/.svg ${NPF_FLAGS} $@
