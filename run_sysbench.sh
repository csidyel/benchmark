#!/bin/bash

TEST=$1
AGENT_TYPE=$2


run_cpu_test() {
  THREADS=(1 `nproc` 100)
  for t in ${THREADS[@]}; do
    BENCHMARK_NAME="CPU_T$t"
    echo "Running CPU benchmark - num of threads: $t"
    duration=$(sysbench cpu --num-threads=$t --cpu-max-prime=5000 --events=1000000 --time=0 run | grep -E 'total time:' | tr '\n' ':' | tr -d " " | awk -F"=|:" '{print $2}' | tr -d 's')
    echo "Publishing $BENCHMARK_NAME with value ${duration}"
  done
}

run_file_io_test(){
  THREADS=(1 `nproc` 100)
  for t in ${THREADS[@]}; do
    BENCHMARK_NAME="IO_10G_T$t"
    sysbench --test=fileio --file-total-size=10G prepare
    sysbench fileio --num-threads=$t --file-total-size=10G --file-test-mode=rndrw --time=20 --max-requests=0 run > output.txt
    read=$(cat output.txt | grep -w 'read' | tr -d ' ' | cut -d ':' -f 2)
    written=$(cat output.txt | grep -w 'written' | tr -d ' ' | cut -d ':' -f 2)
    iops=$(echo "scale=4; ($read + $written) * 1024/16.384" | bc)
    sysbench --test=fileio --file-total-size=10G cleanup
    echo "Publishing $BENCHMARK_NAME IO test 10G file with value Throughput (MiB/s) - read: ${read}, write ${written}, IOPS ${iops}, file size 10G"
  done
}

run_memeory_test(){
  THREADS=(1 `nproc` 100)
  for t in ${THREADS[@]}; do
    BENCHMARK_NAME="MEM_10G_T$t"
    rw=$(sysbench memory --num-threads=$t --memory-total-size=10G run | grep 'transferred' | tr '()' '\n' | grep 'MiB/sec' | cut -d " " -f 1)
    echo "Publishing $BENCHMARK_NAME Memory test 10G, threads: ${t} with value MiB/sec: ${rw}"
  done
}

case "$TEST" in
  "cpu") run_cpu_test;;
  "mem") run_memeory_test;;
  "io") run_file_io_test;;
  *) echo "Available tests: cpu,mem,io"
esac
