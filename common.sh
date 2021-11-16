#!/bin/bash
#NPF_CLUSTER="client=nslrack11-100G,nic=0 dut=nslrack12-100G,nic=1"

NPF_RUNS=${NPF_RUNS:-5}

T1=1

NPF_FLAGS="$NPF_FLAGS --config n_runs=$NPF_RUNS"

#CX5
if [ ${NICABR} = "cx5" ] ; then
    NPF_CLUSTER="client=nslrack12-100G,nic=1 dut=nslrack11-100G,nic=0"
    NPF_FLAGS="$NPF_FLAGS --use-last --variables MODEL=CX5 DUTSOCKET=0 --build-folder ./npf_build/"
    NICNAME="Mellanox Connect-X 5"
fi

#CX5EX
if [ ${NICABR} = "cx5ex" ] ; then
    NPF_CLUSTER="client=nslrack15-100G,nic=0 dut=nslrack16-100G,nic=0"
    NPF_FLAGS="$NPF_FLAGS --use-last --variables MODEL=CX5EX DUTSOCKET=0 --build-folder ./npf_build/"
    NICNAME="Mellanox Connect-X 5 EX"
fi



#CX6
if [ ${NICABR} = "cx6" ] ; then
    NPF_CLUSTER="client=nslrack12-100G,nic=0 dut=nslrack11-100G,nic=2"
    NPF_FLAGS="$NPF_FLAGS --variables MODEL=CX6 DUTSOCKET=1 --use-last"
    NICNAME="Mellanox Connect-X 6"
fi

#CX4
if [ ${NICABR} = "cx4" ] ; then
    #NPF_CLUSTER="client=nslrack12-100G,nic=0 dut=nslrack11-100G,nic=4"
    NPF_CLUSTER="client=nslrack12-100G,nic=3 dut=nslrack11-100G,nic=4"
    NPF_FLAGS="$NPF_FLAGS --variables MODEL=CX4 DUTSOCKET=1 --use-last"
    NICNAME="Mellanox Connect-X 4"
    T1=0
fi

# e810
if [ ${NICABR} = "e810" ] ; then
    NPF_CLUSTER="client=nslrack26-100G,nic=2 dut=nslrack11-100G,nic=6"
    NPF_FLAGS="$NPF_FLAGS --variables MODEL=E810 RULES_ETHERNET=1 DUTSOCKET=0 PAUSE=unset --build-folder ./npf_build/ --config timeout=180 --use-last"
    NICNAME="Intel e810"
    T1=0
fi

#CX6
if [ ${NICABR} = "bf1" ] ; then
    NPF_CLUSTER="client=nslrack11-100G,nic=1 dut=nslrack14-100G,nic=4"
    NPF_FLAGS="$NPF_FLAGS --variables MODEL=CBF DUTSOCKET=0 NICBENCH_PATH=/home/tom/workspace-cascade/nicbench/ --use-last"
    NICNAME="Mellanox BlueField"
    T1=0
    if [ ${USER} = "massimo" ] ; then
	    NPF_FLAGS="$NFP_FLAGS GENSOCKET=0"
    fi
fi
    # nicbench folder depends on user
if [ ${USER} = "massimo" ]; then
	NPF_FLAGS="$NPF_FLAGS --variables  NICBENCH_PATH=/home/massimo/prj/nic-bench-experiments/nicbench/ GENPREFIX=massimoGEN"
else
	NPF_FLAGS="$NPF_FLAGS --variables  NICBENCH_PATH=/home/tom/workspace/nicbench/"
fi

# Compose the tag for the card
if [ ${NICABR} = "e810" ]  || [ ${NICABR} = "e810r" ] ; then
    CARD="e810"
else
    CARD="mlx-${NICABR}"
fi

# Add alias for different paths of npf-compare
if [ ${USER} == "tom" ]; then
    alias npf-compare="python3 ~/npf/npf-compare.py"
elif [ ${USER} == "massimo" ]; then
    alias npf-compare="python3 ~/sw/npf/npf-compare.py"
fi

MYPATH=`realpath $0`
NICBENCH_EXP_PATH=`dirname $MYPATH`


# We want to expand aliases
shopt -s expand_aliases
# And to print the commands before running them
set -o xtrace
