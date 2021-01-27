all: cx4 cx5 cx6 bf1


%:
	#Figure 2, table0, th
	NICABR=$@ ./run_rule_performance_table0_10k.sh
	#Figure 2, table 1+ thr
	NICABR=$@ ./run_ntable_influence.sh
	#figure 2, table 0 latency
	NICABR=$@ ./run_rule_performance_table0_10k_latency.sh
	#figure 2, table 1+ latency
	NICABR=$@ ./run_1table1_latency.sh
	#Figure 3
	NICABR=$@ ./run_update_batch.sh
	#Figure 4
	NICABR=$@ ./run_update_burst.sh
	#Figure 5
	#./run-rule-inst.sh $@ 0 S IPComp yes
	#./run-rule-inst.sh $@ 1 S IPComp yes
	#./run-rule-inst.sh $@ 1 S Tunnels yes
	#./run-rule-inst.sh $@ 1 S Action yes
	#Figure 6
	NICABR=$@ ./run_update_atomic_rate.sh
