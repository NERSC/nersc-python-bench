#!/bin/bash
#SBATCH --account=nstaff
#SBATCH --constraint=haswell
#SBATCH --image=docker:rcthomas/nersc-python-bench-pynamic:0.0.2
#SBATCH --job-name=pynamic-cori-haswell-shifter-003
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rcthomas@lbl.gov
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=32
#SBATCH --output=logs/pynamic-cori-haswell-shifter-003-%j.out
#SBATCH --partition=regular
#SBATCH --qos=normal
#SBATCH --time=30

# Configuration.

commit=false

# Initialize benchmark result.

if [ $commit = true ]; then
    shifter python /usr/local/bin/report-benchmark.py initialize
fi

# Run benchmark.

export OMP_NUM_THREADS=1
unset PYTHONSTARTUP
pynamic_dir=/opt/pynamic-1.3/pynamic-pyMPI-2.6a1

output=tmp/latest-$SLURM_JOB_NAME.txt
srun -c 2 shifter $pynamic_dir/pynamic-pyMPI $pynamic_dir/pynamic_driver.py $(date +%s) | tee $output

# Finalize benchmark result.

if [ $commit = true ]; then
    shifter python /usr/local/bin/report-benchmark.py finalize $( grep elapsed $output | awk '{ print $NF }' )
fi
