#!/bin/bash
source common.sh
modes=( throughput prate )
for mode in "${modes[@]}"; do
    echo "Mode is $mode"
    npf-compare local+nic-rule-inst-bench:${NICABR}-UPDATE --testie ${NICBENCH_EXP_PATH}/nic-live.npf --cluster ${NPF_CLUSTER} --no-build-deps fastclick --show-full --show-cmd --tags promisc iterative --config n_runs=${NPF_RUNS} "graph_variables_as_series={CPU,RPS,MASK}" --variables TABLE=0 PKTGEN_REPLAY_COUNT=500 PKTGEN_REPLAY_TIME=15 --output graphs/${CARD}/skylake/rule-burst-$mode/data/group-0.csv --output-columns x perc1 perc25 median perc75 perc99 avg --result-path result_burst/ --graph-filename tempgraphs/${NICABR}/fig4-table0-$mode/.svg --tags rps $mode ${USER} ${CARD} ${NPF_FLAGS} $@
if [ $T1 != "0" ] ; then
        npf-compare local+nic-rule-inst-bench:${NICABR}-UPDATE --testie ${NICBENC_EXP_PATH}/nic-live.npf --cluster ${NPF_CLUSTER} --no-build-deps fastclick --show-full --show-cmd --tags promisc iterative --config n_runs=${NPF_RUNS} "graph_variables_as_series={CPU,RPS,MASK}" --tags high --variables TABLE=1 PKTGEN_REPLAY_COUNT=500 PKTGEN_REPLAY_TIME=15 --output graphs/${CARD}/skylake/rule-burst-$mode/data/group-1.csv --output-columns x perc1 perc25 median perc75 perc99 avg --result-path result_burst/ --graph-filename tempgraphs/${NICABR}/fig4-table1-$mode/.svg --tags rps $mode $USER ${CARD} ${NPF_FLAGS} $@
fi
done
