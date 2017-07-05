#!/bin/bash 
#SBATCH --account=nstaff
#SBATCH --image=docker:rcthomas/nersc-python-bench:0.3.2
#SBATCH --job-name=pynamic-edison-shifter-200
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rcthomas@lbl.gov
#SBATCH --nodes=200
#SBATCH --ntasks-per-node=24
#SBATCH --output=logs/pynamic-edison-shifter-200-%j.out
#SBATCH --partition=debug
#SBATCH --qos=normal
#SBATCH --time=10

# Configuration.

commit=false

# Environment.

module load shifter
unset PYTHONPATH
unset PYTHONSTARTUP
unset PYTHONUSERBASE
export OMP_NUM_THREADS=1
pynamic_dir=/opt/pynamic-master/pynamic-pyMPI-2.6a1

# Initialize benchmark result.

if [ $commit = true ]; then
    shifter python /usr/local/bin/report-benchmark.py initialize
fi

# Run benchmark.

output=tmp/latest-$SLURM_JOB_NAME.txt
time srun shifter $pynamic_dir/pynamic-pyMPI $pynamic_dir/pynamic_driver.py $(date +%s) | tee $output

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
