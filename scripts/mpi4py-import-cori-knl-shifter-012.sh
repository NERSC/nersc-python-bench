#!/bin/bash
#SBATCH --account=nstaff
#SBATCH --constraint=knl
#SBATCH --core-spec=4
#SBATCH --image=docker:rcthomas/nersc-python-bench:0.3.2
#SBATCH --job-name=mpi4py-import-cori-knl-shifter-012
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rcthomas@lbl.gov
#SBATCH --nodes=12
#SBATCH --ntasks-per-node=8
#SBATCH --output=logs/mpi4py-import-cori-knl-shifter-012-%j.out
#SBATCH --partition=debug
#SBATCH --qos=normal
#SBATCH --time=10

# Configuration.

commit=false

# Environment.

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
srun -c 32 --cpu_bind=cores shifter python /usr/local/bin/mpi4py-import.py $(date +%s) | tee $output

# Finalize benchmark result.

if [ $commit = true ]; then
    shifter python /usr/local/bin/report-benchmark.py finalize $( grep elapsed $output | awk '{ print $NF }' )
fi

shifter python -c 'import sys; print "\n".join(sys.path)'
