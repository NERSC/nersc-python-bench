#!/bin/bash 
#SBATCH --account=nstaff
#SBATCH --constraint=knl
#SBATCH --core-spec=4
#SBATCH --job-name=pynamic-cori-knl-project-012
#SBATCH --license=project
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rcthomas@lbl.gov
#SBATCH --nodes=12
#SBATCH --ntasks-per-node=8
#SBATCH --output=logs/pynamic-cori-knl-project-012-%j.out
#SBATCH --partition=debug
#SBATCH --qos=normal
#SBATCH --time=10

# Configuration.

commit=false

site=nersc-python-bench-site
target_dir=/project/projectdirs/mpccc/$USER/$site/$NERSC_HOST
env_dir=$target_dir/env
pynamic_dir=$target_dir/pynamic-1.3/pynamic-pyMPI-2.6a1

# Environment.

unset PYTHONPATH
unset PYTHONSTARTUP
unset PYTHONUSERBASE
export PYTHONHOME=$env_dir
export LD_LIBRARY_PATH=$pynamic_dir:$LD_LIBRARY_PATH
export PATH=$env_dir/bin:$PATH

# Sanity checks.

which python
python -c 'import sys; print "\n".join(sys.path)'
python -c "import astropy; print astropy.__path__"
strace -f -c python -c "import astropy"

# Initialize benchmark result.

if [ $commit = true ]; then
    python report-benchmark.py initialize
fi

# Run benchmark.

output=tmp/latest-$SLURM_JOB_NAME.txt
time srun -c 32 --cpu_bind=cores $pynamic_dir/pynamic-pyMPI $pynamic_dir/pynamic_driver.py $(date +%s) | tee $output

# Extract result.

startup_time=$( grep '^Pynamic: startup time' $output | awk '{ print $(NF-1) }' )
import_time=$( grep '^Pynamic: module import time' $output | awk '{ print $(NF-1) }' )
visit_time=$( grep '^Pynamic: module visit time' $output | awk '{ print $(NF-1) }' )
total_time=$( echo $startup_time + $import_time + $visit_time | bc )

# Finalize benchmark result.

if [ $commit = true ]; then
    python report-benchmark.py finalize $total_time
fi

# Run for debug information.

export LD_DEBUG=libs
time srun -n 1 $pynamic_dir/pynamic-pyMPI $pynamic_dir/pynamic_driver.py $(date +%s)
