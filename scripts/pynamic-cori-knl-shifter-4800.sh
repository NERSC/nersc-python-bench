#!/bin/bash
#SBATCH --account=nstaff
#SBATCH --constraint=knl
#SBATCH --core-spec=4
#SBATCH --image=docker:rcthomas/nersc-python-bench:0.3.2
#SBATCH --job-name=pynamic-cori-knl-shifter-4800
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rcthomas@lbl.gov
#SBATCH --nodes=4800
#SBATCH --ntasks-per-node=8
#SBATCH --output=logs/pynamic-cori-knl-shifter-4800-%j.out
#SBATCH --partition=regular
#SBATCH --qos=normal
#SBATCH --time=20

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
srun -c 32 --cpu_bind=cores shifter $pynamic_dir/pynamic-pyMPI $pynamic_dir/pynamic_driver.py $(date +%s) | tee $output

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
