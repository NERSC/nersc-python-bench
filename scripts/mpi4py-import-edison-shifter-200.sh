#!/bin/bash
#SBATCH --account=nstaff
#SBATCH --image=docker:rcthomas/nersc-python-bench:0.3.2
#SBATCH --job-name=mpi4py-import-edison-shifter-200
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rcthomas@lbl.gov
#SBATCH --nodes=200
#SBATCH --ntasks-per-node=24
#SBATCH --output=logs/mpi4py-import-edison-shifter-200-%j.out
#SBATCH --partition=regular
#SBATCH --qos=normal
#SBATCH --time=30

# Configuration.

commit=true

# Environment.

module load shifter
unset PYTHONPATH
unset PYTHONSTARTUP
unset PYTHONUSERBASE
export OMP_NUM_THREADS=1

# Initialize benchmark result.

if [ $commit = true ]; then
    shifter python /usr/local/bin/report-benchmark.py initialize
fi

# Run benchmark.

output=tmp/latest-$SLURM_JOB_NAME.txt
srun shifter python /usr/local/bin/mpi4py-import.py $(date +%s) | tee $output

# Finalize benchmark result.

if [ $commit = true ]; then
    shifter python /usr/local/bin/report-benchmark.py finalize $( grep elapsed $output | awk '{ print $NF }' )
fi
