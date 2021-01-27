# NIC Bench experiments

The experiments are managed using [NPF](http://github.com/tbarbette/npf/), it will run the experiments presented in the NIC Bench paper multiple times. NPF will download and installed dependencies such as FastClick and the NIC-bench core. However the updated DPDK with the update API require external implementation.


## Dependencies and set-up

 * Install NPF with `python3 -m pip install --user npf`
 * Set up the NPF parameters (see the NPF page) such as the cluster in common.sh


## Running

Just type make :) The experiments will produce automatically the files.


## Results of experiments (including other NICs)

Data for CX4, CX5 and CX6 can be found in the `plots` folder. BF1 is coming, stay tuned !

