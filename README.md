# NIC Bench experiments

The experiments are managed using [NPF](http://github.com/tbarbette/npf/), it will run the experiments presented in the NIC Bench paper multiple times. NPF will download and installed dependencies such as FastClick and the NIC-bench core. However the updated DPDK with the update API require external implementation.


## Dependencies and set-up

 * Install NPF and psutil with `python3 -m pip install --user npf psutil`
 * Install DPDK (see dpdk.org), or our [modified version of DPDK](http://github.com/nicbench/dpdk/) if you want to test the new update API:
 ```bash
 # Extract sources

   tar xf dpdk.tar.gz
   cd dpdk

 # Build libraries, drivers and test applications.
   meson build
   ninja -C build
   sudo ninja -C build install
 ```
 * Compile our modified version of FastClick

```
git clone https://github.com/nic-bench/fastclick.git
cd fastclick
./configure --enable-dpdk --enable-intel-cpu --verbose --enable-select=poll CFLAGS="-O3" CXXFLAGS="-std=c++11 -O3"  --disable-dynamic-linking --enable-poll --enable-bound-port-transfer --enable-local --enable-flow --disable-task-stats --disable-cpu-load
make
export NICBENCH_PATH=$(pwd)
```

## Running

We provide a Makefile to automatically run all tests. However it is best to start with a simplified experiment to verify the setup is working:

### Running a single benchmark

With will run the Figure 2 test, measuring throughput and latency for table 0 for a various amount of rules.
```
npf-compare local --test nic-occupancy.npf \
    --cluster client=server0.mycluster.com dut=server1.mycluster.com \
    --variables PC=0 PORTS=0 PRIORITY=1 USE_UPSTREAM_DPDK=1 TABLE=0 MODEL=CX5 DUTSOCKET=0 NICBENCH_PATH=/home/tom/workspace/nicbench/ \
    --tags small nomatchresults
```
If something is going wrong, add --show-full --show-cmd to see the commands and their output and try to solve the issue.

If everything goes smoothly, at the end of the tests you will have a path to automatically generated graphs such as this one for throughput:
![Throughput for the example command](nic-occupancy-example-0.svg)

The file nic-occupancy.npf contains a description of the variables that can be changed, for instance fixing the number of rules to 1000000, using table 1 instead of table 0 and using 1000 to 100000 flows in the input load can be done with `--variables NRULES=1000000 TABLE=1 NFLOWS={1000,10000,100000}`.


### Running all tests
Set up the parameters such as the cluster's IP addresses (the machines where the NIC are installed) and the path to the modified FastClick in common.sh

When it works, just type make to run all experiments. The experiments will produce automatically the files.


## Results of experiments (including other NICs)

Data for CX4, CX5 and CX6 can be found in the `plots` folder. BF1 is coming, stay tuned !

