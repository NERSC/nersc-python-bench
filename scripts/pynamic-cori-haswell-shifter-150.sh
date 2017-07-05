#!/bin/bash
#SBATCH --account=nstaff
#SBATCH --constraint=haswell
#SBATCH --image=docker:rcthomas/nersc-python-bench:0.3.2
#SBATCH --job-name=pynamic-cori-haswell-shifter-150
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rcthomas@lbl.gov
#SBATCH --nodes=150
#SBATCH --ntasks-per-node=32
#SBATCH --output=logs/pynamic-cori-haswell-shifter-150-%j.out
#SBATCH --partition=regular
#SBATCH --qos=premium
#SBATCH --time=10

# Configuration.

commit=false

# Initialize benchmark result.

if [ $commit = true ]; then
    shifter python /usr/local/bin/report-benchmark.py initialize
fi

# Run benchmark.

export OMP_NUM_THREADS=1
unset PYTHONSTARTUP
pynamic_dir=/opt/pynamic-master/pynamic-pyMPI-2.6a1

output=tmp/latest-$SLURM_JOB_NAME.txt
srun -c 2 shifter $pynamic_dir/pynamic-pyMPI $pynamic_dir/pynamic_driver.py $(date +%s) | tee $output

# Extract result.

startup_time=$( grep '^Pynamic: startup time' $output | awk '{ print $(NF-1) }' )
import_time=$( grep '^Pynamic: module import time' $output | awk '{ print $(NF-1) }' )
visit_time=$( grep '^Pynamic: module visit time' $output | awk '{ print $(NF-1) }' )
total_time=$( echo $startup_time + $import_time + $visit_time | bc )
echo total_time $total_time s

# Finalize benchmark result.

if [ $commit = true ]; then
    shifter python /usr/local/bin/report-benchmark.py finalize $total_time
fi
