all:
	#Figure 2, table0
	./run_rule_performance_table0_10k.sh
	#Figure 2, table 1+
	./run_ntable_influence.sh
	#Figure 3
	./run-update-batch.sh
	#Figure 4
	./run-update-burst.sh

