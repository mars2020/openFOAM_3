#!/bin/bash
#----------------------------------------------------
# Sample Slurm job script
#   for TACC Stampede2 KNL nodes
#
#   *** Serial Job on Normal Queue ***
#
# Last revised: 20 Oct 2017
#
# Notes:
#
#   -- Copy/edit this script as desired.  Launch by executing
#      "sbatch knl.serial.slurm" on a Stampede2 login node.
#
#   -- Serial codes run on a single node (upper case N = 1).
#        A serial code ignores the value of lower case n,
#        but slurm needs a plausible value to schedule the job.
#
#   -- For a good way to run multiple serial executables at the
#        same time, execute "module load launcher" followed
#        by "module help launcher".

#----------------------------------------------------

#SBATCH -J of           # Job name
#SBATCH -o of.o%j       # Name of stdout output file
#SBATCH -e of.e%j       # Name of stderr error file
#SBATCH -p normal          # Queue (partition) name
#SBATCH -N 1               # Total # of nodes (must be 1 for serial)
#SBATCH -n 1               # Total # of mpi tasks (should be 1 for serial)
#SBATCH -t 00:10:00        # Run time (hh:mm:ss)
###  #SBATCH --mail-user=youremail@utexas.edu
###  #SBATCH --mail-type=all    # Send email at begin and end of job
#SBATCH -A COE-347-SP2019       # Allocation name (req'd if you have more than 1)

# Other commands must follow all #SBATCH directives...

module purge
module load intel/18.0.2  impi/18.0.2 openfoam/6.0
module list

pwd
date

# Launch serial code(s)...

# this creates the mesh
blockMesh

# this checks the mesh
checkMesh

# run the solver 
rhoCentralFoam

# extract the graphs
postProcess -func graph

# ---------------------------------------------------
