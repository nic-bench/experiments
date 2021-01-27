#!/bin/bash
source common.sh
~/npf/npf-compare.py local+nic-rule-inst-bench:${NICABR}-UPDATE --testie ~/workspace/nic-bench-experiments/nic-live.testie --cluster ${NPF_CLUSTER} --show-full --show-cmd --tags promisc iterative --config n_runs=${NPF_RUNS} "graph_variables_as_series={CPU,RPS,RULES,MASK}" --variables TABLE=0 PKTGEN_REPLAY_COUNT=500 PKTGEN_REPLAY_TIME=15 --output graphs/mlnx-${NICABR}/skylake/rule-batch-rate/data/group-0/.csv --output-columns x perc1 perc25 median perc75 perc99 avg --result-path result_batch/ --graph-filename tempgraphs/${NICABR}/fig3table0/.svg --tags batch mlnx-${NICABR} ${NPF_FLAGS} $@
if [ T1 != "0" ] ; then
    ~/npf/npf-compare.py local+nic-rule-inst-bench:${NICABR}-UPDATE --testie ~/workspace/nic-bench-experiments/nic-live.testie --cluster ${NPF_CLUSTER} --no-build-deps fastclick --show-full --show-cmd --tags promisc iterative --config n_runs=${NPF_RUNS} "graph_variables_as_series={CPU,RPS,RULES,MASK}" --variables TABLE=1 PKTGEN_REPLAY_COUNT=500 PKTGEN_REPLAY_TIME=15 --output graphs/mlnx-${NICABR}/skylake/rule-batch-rate/data/group-1/.csv --output-columns x perc1 perc25 median perc75 perc99 avg --result-path result_batch/ --graph-filename tempgraphs/${NICABR}/fig3table1/.svg --tags batch mlnx-${NICABR} ${NPF_FLAGS} $@
fi
