#!/bin/bash

##### These lines are for Slurm
#SBATCH --nodes=10
#SBATCH --ntasks-per-node=40
#SBATCH --job-name=6G
#SBATCH --time=24:00:00
#SBATCH --qos=scavenger
#SBATCH --partition=scavenger
#SBATCH --qos=supporters
#SBATCH --partition=general-compute
#SBATCH --mail-type=ALL
#SBATCH --exclusive
#SBATCH --account=chrest
#SBATCH --mail-user=jpdening@buffalo.edu
#SBATCH --requeue

##### Load Required modules
# gcc
module load intel/20.2
module load intel-mpi/2020.2
module load gcc/11.2.0
module load cmake/3.22.3
module load valgrind/3.14.0
module load gdb/7.8

# srun stuff
export I_MPI_PMI_LIBRARY=/usr/lib64/libpmi.so
export TEST_MPI_COMMAND=srun

# Load PETSC ENV
export PETSC_DIR="/projects/academic/chrest/jpdening/petsc"
export PETSC_ARCH="arch-ablate-opt" # arch-ablate-debug or arch-ablate-opt
export PKG_CONFIG_PATH="${PETSC_DIR}/${PETSC_ARCH}/lib/pkgconfig:$PKG_CONFIG_PATH"
export HDF5_ROOT="${PETSC_DIR}/${PETSC_ARCH}"  
# Include the bin directory to access mpi commands
export PATH="${PETSC_DIR}/${PETSC_ARCH}/bin:$PATH"

# Make a temp directory so that tchem has a place to vomit its files
mkdir tmp_$SLURM_JOBID
cd tmp_$SLURM_JOBID

export TITLE=6G-10
export VELOCITY="min(3.985120454,t*3.985120454/.01),0.0,0.0"

##### Launch parallel job using srun
srun -n $SLURM_NPROCS /projects/academic/chrest/jpdening/ablateOpt/ablate \
	--input /panasas/scratch/grp-chrest/jpdening/ablateInputs/slabBurner3D/slabBurner.3D.ccr.yaml \
	-yaml::environment::title $TITLE \
    -yaml::solvers::[1]::processes::[0]::velocity \"$VELOCITY\"

echo 'Done'
