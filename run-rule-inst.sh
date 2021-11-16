#!/bin/bash

# Usage:
#    ./run-rule-inst.sh 82599 0 S Match yes
#    ./run-rule-inst.sh xl710 0 S Match yes
#    ./run-rule-inst.sh cx4 0 S Match yes
#    ./run-rule-inst.sh cx5 0 S IPCOMP yes
#    ./run-rule-inst.sh cx5 1 S IPCOMP yes
#    ./run-rule-inst.sh cx6 0 S Match yes
#    ./run-rule-inst.sh bf1 0 S Match yes

source common.sh

NPF_PATH=$(dirname $(realpath $(which npf-run)))
SUCCESS=0
ERROR=1

PROGRAM=${0}
SYSTEM=${1}
NIC_GROUP=${2:-0}
RULESET_SIZE=${3:-S}
SCENARIO=${4:-Match}
FORCE_RETEST=${5:-no}

SYSTEMS=("82599" "xl710" "cx4" "cx5" "cx6" "bf1" "e810")
SCENARIOS=("Match" "Action" "IPComp" "Slicing" "IntelAction" "IntelMatch")

CUR_PATH=$(pwd)
TESTIE_PATH=$(pwd)/nic-rule-inst-bench.npf

COMMAND=""
DUT=""
HW_ARCH="skylake"
NIC_VENDOR=""
NIC_MODEL=""
RULES_NB=""
RULESET_LABEL=""
EXTRA_TAG=""
MATCH_OPS=""
ACTION_OPS=""
SCENARIO_LABEL=""
OUT_FILE=""
ITERATIONS_NB=3

usage()
{
	echo "Usage: "${PROGRAM}" <NIC-Model (82599/xl710/cx4/cx5/cx6/bf1/e810)> <Group No (>=0)> <Ruleset Size (S/L)> <Scenario (Match/Action/IPComp/Tunnels/IntelAction/IntelMatch)> <Force retest (yes/no)>"
	exit $ERROR
}


check_input()
{
	if [[ ! -d $NPF_PATH ]]; then
		echo "NPF not found at: "$NPF_PATH
		exit $ERROR
	fi

	if [[ ! -f $TESTIE_PATH ]]; then
		echo "Testie not found at: "$TESTIE_PATH
		exit $ERROR
	fi

	SYSTEMS_ARRAY=$(echo ${SYSTEMS[@]} | fgrep --word-regexp $SYSTEM | wc -l)
	if [[ $SYSTEMS_ARRAY == 0 ]]; then
		echo "Wrong system. Please choose a system in: "${SYSTEMS[@]}
		exit $ERROR
	fi

	if [[ $NIC_GROUP -lt 0 ]]; then
		echo "NIC flow table number must be positive"
		usage
	fi

	if [[ $NIC_GROUP -eq 0 ]]; then
		EXTRA_TAG="limit-batch-win"
	fi

	if [[ ! $RULESET_SIZE =~ ^(S|L|M)$ ]]; then
		echo "NIC ruleset size must be either S (Small) or L (Large)"
		usage
	fi

	if [[ $RULESET_SIZE == "S" ]]; then
		RULESET_LABEL="small"
		EXTRA_TAG="limit-batch-win"
	else
		RULESET_LABEL="large"
	fi

	if [[ $SCENARIO =~ ^(match|Match|MATCH)$ ]]; then
		MATCH_OPS="{--ether,--ether --vlan,--ether --vlan --ipv4,--ether --vlan --ipv4 --tcp}"
		ACTION_OPS="{--queue}"
		SCENARIO_LABEL="inc-match"
	fi

	if [[ $SCENARIO =~ ^(action|Action|ACTION)$ ]]; then
		MATCH_OPS="{--ether}"
		ACTION_OPS="{--queue,--mark --queue,--mark --set-meta --queue,--mark --set-meta --set-tag --queue}"
		SCENARIO_LABEL="inc-action"
	fi
	if [[ $SCENARIO =~ ^(intelaction|IntelAction|INTELACTION)$ ]]; then
		MATCH_OPS="{--ether --ipv4}"
		ACTION_OPS="{--queue,--mark --queue,--count --queue,--mark --count --queue, --drop, --mark --drop, --count --drop, --mark --count --drop}"
		SCENARIO_LABEL="inc-intel-action"
	fi
	if [[ $SCENARIO =~ ^(intelmatch|IntelMatch|INTELMATCH)$ ]]; then
		MATCH_OPS="{--ether --ipv4, --ether --ipv6, --ether --vlan, --ether --ipv4 --udp --gtpu, --ether --ipv6 --udp --gtpu, --ether --ipv4 --tcp, --ether --ipv6 --tcp, --ether --ipv4 --udp, --ether --ipv6 --udp, --eth --pppoes, --eth --ipv4 --ah, --eth --ipv6 --ah, --eth --ipv4 --esp, --eth --ipv6 --esp, --eth --ipv4 --l2tpv3oip, --eth --ipv6 --l2tpv3oip}"
		ACTION_OPS="{--queue}"
		SCENARIO_LABEL="inc-intel-match"
	fi

	if [[ $SCENARIO =~ ^(ipcomp|IpComp|IPComp|IPCOMP)$ ]]; then
		if [[ $NICABR != "e810" ]]; then
			MATCH_OPS="{--ether,--ether --ipv4,--ether --ipv6,--ether --ipv4 --tcp,--ether --ipv6 --tcp}"
		else
			MATCH_OPS="{--ether --ipv4,--ether --ipv6,--ether --ipv4 --tcp,--ether --ipv6 --tcp}"
		fi
		ACTION_OPS="{--queue}"
		SCENARIO_LABEL="ipv4-vs-ipv6"
	fi

	if [[ $SCENARIO =~ ^(slicing|Slicing|SLICING)$ ]]; then
		MATCH_OPS="{--ether,--ether --vlan,--ether --vlan --ipv4,--ether --vlan --ipv6,--ether --vlan --ipv4 --tcp,--ether --vlan --ipv6 --tcp,--ether --vxlan --ipv4 --udp,--ether --gre --ipv4,--ether --gre --ipv4 --udp,--ether --gre --ipv4 --tcp,--ether --geneve --ipv4 --udp}"
		ACTION_OPS="{--queue}"
		SCENARIO_LABEL="slicing"
	fi

	if [[ (-z $MATCH_OPS) || (-z $ACTION_OPS) ]]; then
		usage
	fi

	if [[ ! $FORCE_RETEST =~ ^(yes|Yes|YES|no|No|NO)$ ]]; then
		echo "Force retest option requires a simple yes or no"
		usage
	fi

	if [[ $FORCE_RETEST =~ ^(no|No|NO)$ ]]; then
		FORCE_RETEST=""
	else
		FORCE_RETEST="--force-retest"
	fi

	return $SUCCESS
}

compose_rule_inst_intel_82599()
{
	DUT="nslrack07-10G,nic=0"
	NIC_VENDOR="intel"
	NIC_MODEL="82599"

	if [[ $NIC_GROUP -ne 0 ]]; then
		echo "This NIC provides only a single flow rule table"
		usage
	fi

	if [[ $RULESET_SIZE == "S" ]]; then
		RULES_NB="{2,10,20,30,40,50,60,70,80,90,100,128}"
	else
		RULES_NB="{2,100,1000,2000,3000,4000,5000,6000,7000,7680}"
	fi
}

compose_rule_inst_intel_xl710()
{
	DUT="nslrack14-100G,nic=6"
	NIC_VENDOR="intel"
	NIC_MODEL="xl710"

	if [[ $NIC_GROUP -ne 0 ]]; then
		echo "This NIC provides only a single flow rule table"
		usage
	fi

	if [[ $RULESET_SIZE == "S" ]]; then
		RULES_NB="{2,10,20,30,40,50,60,70,80,90,100,128}"
	else
		RULES_NB="{2,100,1000,2000,3000,4000,5000,6000,7000,7680}"
	fi
}

compose_rule_inst_mlnx_cx4()
{
	DUT="nslrack11-100G,nic=0"
	NIC_VENDOR="mlnx"
	NIC_MODEL="cx4"

	# if [[ $NIC_GROUP -ne 0 ]]; then
	# 	echo "This NIC provides only a single flow rule table"
	# 	usage
	# fi

	if [[ $RULESET_SIZE == "S" ]]; then
		RULES_NB="{2,16000,32000,56000,57000,58000,59000,60000,61000,62000,63000,64000,65000,65464}"
	else
		RULES_NB="{100000,200000,300000,400000,500000,600000,700000,800000,900000,1000000,2000000,3000000,4000000}"
	fi
}

compose_rule_inst_mlnx_cx5()
{
	DUT="nslrack11-100G,nic=2"
	NIC_VENDOR="mlnx"
	NIC_MODEL="cx5"

	if [[ $RULESET_SIZE == "S" ]]; then
		RULES_NB="{2,16000,32000,56000,57000,58000,59000,60000,61000,62000,63000,64000,65000,65536}"
	else
		RULES_NB="{100000,200000,300000,400000,500000,600000,700000,800000,900000,1000000,2000000,3000000,4000000}"
	fi
}

compose_rule_inst_mlnx_cx6()
{
	DUT="nslrack11-100G,nic=4"
	NIC_VENDOR="mlnx"
	NIC_MODEL="cx6"

	if [[ $RULESET_SIZE == "S" ]]; then
		RULES_NB="{2,16000,32000,56000,57000,58000,59000,60000,61000,62000,63000,64000,65000,65536}"
	else
		RULES_NB="{100000,200000,300000,400000,500000,600000,700000,800000,900000,1000000,2000000,3000000,4000000}"
	fi
}

compose_rule_inst_mlnx_bf1()
{
	DUT="nslrack14-100G,nic=4"
	NIC_VENDOR="mlnx"
	NIC_MODEL="bf1"

	# if [[ $NIC_GROUP -ne 0 ]]; then
	# 	echo "This NIC provides only a single flow rule table"
	# 	usage
	# fi

	if [[ $RULESET_SIZE == "S" ]]; then
		RULES_NB="{2,16000,32000,56000,57000,58000,59000,60000,61000,62000,63000,64000,65000,65536}"
	else
		RULES_NB="{100000,200000,300000,400000,500000,600000,700000,800000,900000,1000000,2000000,3000000,4000000}"
	fi
}

compose_rule_inst_intel_e810()
{
	DUT="nslrack11-100G,nic=6"
	NIC_VENDOR="intel"
	NIC_MODEL="e810"

	if [[ $NIC_GROUP -ne 0 ]]; then
		echo "This NIC provides only a single flow rule table"
		usage
	fi

	if [[ $RULESET_SIZE == "S" ]]; then
		RULES_NB="{2,10,20,30,40,50,60,70,80,90,100,128}"
	else
		RULES_NB="{2,10,20,30,40,50,60,70,80,90,100,128,140,160,180,200,220,240,250,256,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,11000,12000,13000,14000,15000,15360}"
	fi
}

compose_out_file()
{
    OUT_FILE="graphs/mlnx-${NICABR}/${HW_ARCH}/rule-inst-bench/rule-inst-bench-${HW_ARCH}-${NIC_VENDOR}-${NIC_MODEL}-set-${RULESET_LABEL}-group-${NIC_GROUP}-scenario-${SCENARIO_LABEL}.csv"
}

print_configuration()
{
	echo " Processing Server: "$DUT
	echo "   HW Architecture: "$HW_ARCH
	echo "  NIC       Vendor: "$NIC_VENDOR
	echo "  NIC        Model: "$NIC_MODEL
	echo "  NIC Group Number: "$NIC_GROUP
	echo "  NIC Rules Number: "$RULES_NB
	echo "          Scenario: "$SCENARIO
	echo "   # of Iterations: "$ITERATIONS_NB
	echo "      Force retest: "$FORCE_RETEST
	echo "       Output file: "$OUT_FILE
}

compose_cmd()
{
    COMMAND="npf-compare \
		local+nic-rule-inst-bench:${NIC_MODEL}-G${NIC_GROUP}-${RULESET_SIZE}-${SCENARIO_LABEL} \
		--testie $TESTIE_PATH --cluster dut=${DUT} \
		--tags $USER ${NIC_VENDOR}-${NIC_MODEL} ${EXTRA_TAG} \
		--variables TARGET_NIC_PORT=0 FLOW_RULES_NB=\"${RULES_NB}\" \
		FLOW_GROUP_NB=${NIC_GROUP} \
		MATCH_OPS=\"${MATCH_OPS}\" \
		ACTION_OPS=\"${ACTION_OPS}\" \
		--output ${OUT_FILE} \
		--output-columns x perc1 perc25 median perc75 perc99 avg \
        --graph-filename tempgraphs/${NICABR}/fig5-${NIC_GROUP}-${SCENARIO_LABEL}/.svg \
		--show-cmd --show-full --config n_runs=$ITERATIONS_NB $FORCE_RETEST ${PARAMS}"

	echo ""
	echo $COMMAND

	eval $COMMAND
}

check_input

if [[ $SYSTEM == "82599" ]]; then
	compose_rule_inst_intel_82599
elif [[ $SYSTEM == "xl710" ]]; then
	compose_rule_inst_intel_xl710
elif   [[ $SYSTEM == "cx4" ]]; then
	compose_rule_inst_mlnx_cx4
elif [[ $SYSTEM == "cx5" ]]; then
	compose_rule_inst_mlnx_cx5
elif [[ $SYSTEM == "cx6" ]]; then
	compose_rule_inst_mlnx_cx6
elif [[ $SYSTEM == "bf1" ]]; then
	compose_rule_inst_mlnx_bf1
elif [[ $SYSTEM == "e810" ]]; then
	compose_rule_inst_intel_e810
fi
compose_out_file

print_configuration
compose_cmd


exit 0
