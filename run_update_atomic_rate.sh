#!/bin/bash
#Rate of rule installation, dos not live traffic
source common.sh
if [ $T1 -eq 1 ] ; then
    ~/npf/npf-compare.py dpdk+nic-rule-inst-bench:UPDATE --testie ~/workspace/nic-bench-experiments/nic-rule-inst-bench.npf --cluster ${NPF_CLUSTER} --variables TARGET_NIC_PORT=0 FLOW_GROUP_NB=1 MATCH_OPS="{--ipv4}" ACTION_OPS="{--queue}" --output graphs/mlnx-${NICABR}/skylake/rule/update-rate/group-1/ --output-columns x perc1 perc25 median perc75 perc99 avg --show-cmd --show-full --config n_runs=3 --variables DPDK_REPO=/home/tom/workspace/dpdk-updated/ --tags limit-batch-win atomic simple mlnx-${NICABR} --graph-filename tempgraphs/${NICABR}/fig6/.svg ${NPF_FLAGS} $@
fi
