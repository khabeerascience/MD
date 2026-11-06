#!/bin/bash
#PBS -N gmx
#PBS -l nodes=1:ncpus=10
#PBS -l walltime=48:00:00
#PBS -q Gpu6-40g
#PBS -o host.out
#PBS -e host_err


# Load GROMACS module
module load gromacs/2022

# Define working directory and production run prefix
#path='/storage/home/arjun/khabeera/peptide_simulation/2.2_DQ2.5_sec_3/'
gmx_path='/storage/softare/gromacs-2022/bin/'

gpu_id="MIG-7d12099a-0109-526e-8046-9af32cc49bd6"

# Loop through each PDB file in current directory
pdb="minimized_frame0.pdb"
name="${pdb%.pdb}"
echo "=== Processing $name ==="

base_path="/storage/home/arjun/khabeera/Water_Dynamics/ecoli/fs_sim_tip4p/t1"
cd "$base_path"

# Make a directory and move the pdb file
mkdir -p "$name"
cp -r "$pdb" "$name/"
cd "$base_path/$name"


#Construct The .mdp Files
echo '
integrator  = steep         ; Algorithm (steep = steepest descent minimization)
emtol       = 1000.0        ; Stop minimization when the maximum force < 1000.0 kJ/mol/nm
emstep      = 0.01          ; Minimization step size
nsteps      = 50000         ; Maximum number of (minimization) steps to perform

; Parameters describing how to find the neighbors of each atom and how to calculate the interactions
nstlist         = 1         ; Frequency to update the neighbor list and long range forces
cutoff-scheme	= Verlet    ; Buffered neighbor searching 
ns_type         = grid      ; Method to determine neighbor list (simple, grid)
coulombtype     = cutoff    ; Treatment of long range electrostatic interactions
rcoulomb        = 1.0       ; Short-range electrostatic cut-off
rvdw            = 1.0       ; Short-range Van der Waals cut-off
pbc             = xyz       ; Periodic Boundary Conditions in all 3 dimensions
'>>ions.mdp

echo '
integrator  = steep         ; Algorithm (steep = steepest descent minimization)
emtol       = 1000.0        ; Stop minimization when the maximum force < 1000.0 kJ/mol/nm
emstep      = 0.01          ; Minimization step size
nsteps      = 50000         ; Maximum number of (minimization) steps to perform

; Parameters describing how to find the neighbors of each atom and how to calculate the interactions
nstlist         = 1         ; Frequency to update the neighbor list and long range forces
cutoff-scheme   = Verlet    ; Buffered neighbor searching
ns_type         = grid      ; Method to determine neighbor list (simple, grid)
coulombtype     = PME       ; Treatment of long range electrostatic interactions
rcoulomb        = 1.0       ; Short-range electrostatic cut-off
rvdw            = 1.0       ; Short-range Van der Waals cut-off
pbc             = xyz       ; Periodic Boundary Conditions in all 3 dimensions
'>>em.mdp

echo '
define               = -DPOSRES            ; position restrain the protein
; Run parameters
integrator           = md                  ; leap-frog integrator
nsteps               = 50000               ; 2 * 50000 = 100 ps
dt                   = 0.002               ; 2 fs
; Output control
nstxout              = 500                 ; save coordinates every 1.0 ps
nstvout              = 500                 ; save velocities every 1.0 ps
nstenergy            = 500                 ; save energies every 1.0 ps
nstlog               = 500                 ; update log file every 1.0 ps
; Bond parameters
continuation         = no                  ; first dynamics run
constraint_algorithm = lincs               ; holonomic constraints 
constraints          = all-bonds           ; all bonds (even heavy atom-H bonds) constrained
lincs_iter           = 1                   ; accuracy of LINCS
lincs_order          = 4                   ; also related to accuracy
; Neighborsearching
cutoff-scheme        = Verlet
ns_type              = grid                ; search neighboring grid cells
nstlist              = 10                  ; 20 fs, largely irrelevant with Verlet
rcoulomb             = 1.0                 ; short-range electrostatic cutoff (in nm)
rvdw                 = 1.0                 ; short-range van der Waals cutoff (in nm)
; Electrostatics
coulombtype          = PME                 ; Particle Mesh Ewald for long-range electrostatics
pme_order            = 4                   ; cubic interpolation
fourierspacing       = 0.16                ; grid spacing for FFT
; Temperature coupling is on
tcoupl               = V-rescale           ; modified Berendsen thermostat
tc-grps              = Protein Non-Protein ; two coupling groups - more accurate
tau_t                = 0.1  0.1            ; time constant, in ps
ref_t                = 300  300            ; reference temperature, one for each group, in K
; Pressure coupling is off
pcoupl               = no                  ; no pressure coupling in NVT
; Periodic boundary conditions
pbc                  = xyz                 ; 3-D PBC
; Dispersion correction
DispCorr             = EnerPres            ; account for cut-off vdW scheme
; Velocity generation
gen_vel              = yes                 ; assign velocities from Maxwell distribution
gen_temp             = 300                 ; temperature for Maxwell distribution
gen_seed             = -1                  ; generate a random seed
'>>nvt.mdp

echo '
define               = -DPOSRES            ; position restrain the protein
; Run parameters
integrator           = md                  ; leap-frog integrator
nsteps               = 50000               ; 2 * 50000 = 100 ps
dt                   = 0.002               ; 2 fs
; Output control
nstxout              = 500                 ; save coordinates every 1.0 ps
nstvout              = 500                 ; save velocities every 1.0 ps
nstenergy            = 500                 ; save energies every 1.0 ps
nstlog               = 500                 ; update log file every 1.0 ps
; Bond parameters
continuation         = yes                 ; Restarting after NVT 
constraint_algorithm = lincs               ; holonomic constraints 
constraints          = all-bonds           ; all bonds (even heavy atom-H bonds) constrained
lincs_iter           = 1                   ; accuracy of LINCS
lincs_order          = 4                   ; also related to accuracy
; Neighborsearching
cutoff-scheme        = Verlet
ns_type              = grid                ; search neighboring grid cells
nstlist              = 10                  ; 20 fs, largely irrelevant with Verlet scheme
rcoulomb             = 1.0                 ; short-range electrostatic cutoff (in nm)
rvdw                 = 1.0                 ; short-range van der Waals cutoff (in nm)
; Electrostatics
coulombtype          = PME                 ; Particle Mesh Ewald for long-range electrostatics
pme_order            = 4                   ; cubic interpolation
fourierspacing       = 0.16                ; grid spacing for FFT
; Temperature coupling is on
tcoupl               = V-rescale           ; modified Berendsen thermostat
tc-grps              = Protein Non-Protein ; two coupling groups - more accurate
tau_t                = 0.1  0.1            ; time constant, in ps
ref_t                = 300  300            ; reference temperature, one for each group, in K
; Pressure coupling is on
pcoupl               = Parrinello-Rahman   ; Pressure coupling on in NPT
pcoupltype           = isotropic           ; uniform scaling of box vectors
tau_p                = 2.0                 ; time constant, in ps
ref_p                = 1.0                 ; reference pressure, in bar
compressibility      = 4.5e-5              ; isothermal compressibility of water, bar^-1
refcoord_scaling     = com
; Periodic boundary conditions
pbc                  = xyz                 ; 3-D PBC
; Dispersion correction
DispCorr             = EnerPres            ; account for cut-off vdW scheme
; Velocity generation
gen_vel              = no                  ; Velocity generation is off 
'>>npt.mdp

echo '
; Run parameters
integrator              = md        ; leap-frog integrator
nsteps                  = 100000   ; 1 * 100000 = 100 ps (0.2 ns)
dt                      = 0.001     ; 1 fs
; Output control
nstenergy               = 1      ; save energies every 1.0 fs
nstlog                  = 1      ; update log file every 1.0 fs
nstxout-compressed      = 1      ; save coordinates every 1.0 fs
; Bond parameters
continuation            = no       ; continuing from NPT 
constraint_algorithm    = lincs     ; holonomic constraints 
constraints             = h-bonds   ; bonds to H are constrained
lincs_iter              = 1         ; accuracy of LINCS
lincs_order             = 4         ; also related to accuracy
; Neighbor searching and vdW
cutoff-scheme           = Verlet
ns_type                 = grid      ; search neighboring grid cells
nstlist                 = 20        ; largely irrelevant with Verlet
rlist                   = 1.2
vdwtype                 = cutoff
vdw-modifier            = force-switch
rvdw-switch             = 1.0
rvdw                    = 1.2       ; short-range van der Waals cutoff (in nm)
; Electrostatics
coulombtype             = PME       ; Particle Mesh Ewald for long-range electrostatics
rcoulomb                = 1.2
pme_order               = 4         ; cubic interpolation
fourierspacing          = 0.16      ; grid spacing for FFT
; Temperature coupling
tcoupl                  = Nose-Hoover                     ; modified Berendsen thermostat
tc-grps                 = Protein Water_SOD    ; two coupling groups - more accurate
tau_t                   = 0.5   0.5                     ; time constant, in ps
ref_t                   = 300   300                     ; reference temperature, one for each group, in K
; Pressure coupling 
pcoupl                  = Parrinello-Rahman             ; pressure coupling is on for NPT
pcoupltype              = isotropic                     ; uniform scaling of box vectors
tau_p                   = 2.0                           ; time constant, in ps
ref_p                   = 1.0                           ; reference pressure, in bar
compressibility         = 4.5e-5                        ; isothermal compressibility of water, bar^-1
; Periodic boundary conditions
pbc                     = xyz       ; 3-D PBC
; Dispersion correction is not used for proteins with the C36 additive FF
DispCorr                = no 
; Velocity generation
gen_vel                 = no        ; continuing from NPT equilibration 
'>>md.mdp

# Prepare The System
printf %s\\n 1 | $gmx_path/gmx pdb2gmx -f "$name.pdb" -o "$name.gro" -water spce -ignh
$gmx_path/gmx editconf -f "$name.gro" -o "${name}_box.gro" -c -d 6.0 -bt dodecahedron
$gmx_path/gmx solvate -cp "${name}_box.gro" -cs spc216.gro -o "${name}_solv.gro" -p topol.top
$gmx_path/gmx grompp -f ions.mdp -c "${name}_solv.gro" -p topol.top -o ions.tpr -maxwarn 1
printf %s\\n 13 | $gmx_path/gmx genion -s ions.tpr -o "${name}_solv_ions.gro" -p topol.top -pname NA -nname CL -neutral
$gmx_path/gmx grompp -f em.mdp -c "${name}_solv_ions.gro" -p topol.top -o em.tpr
CUDA_VISIBLE_DEVICES=$gpu_id $gmx_path/gmx mdrun -deffnm $base_path/$name/em  -ntmpi 1 -ntomp 10
$gmx_path/gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -o nvt.tpr
CUDA_VISIBLE_DEVICES=$gpu_id $gmx_path/gmx mdrun -deffnm $base_path/$name/nvt -nb gpu -bonded gpu -pme gpu -ntmpi 1 -ntomp 10
$gmx_path/gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p topol.top -o npt.tpr
CUDA_VISIBLE_DEVICES=$gpu_id $gmx_path/gmx mdrun -deffnm $base_path/$name/npt -nb gpu -bonded gpu -pme gpu -ntmpi 1 -ntomp 10
$gmx_path/gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o md.tpr

# Run molecular dynamics simulation on specific GPU
#CUDA_VISIBLE_DEVICES=$gpu_id $gmx_path/gmx mdrun -deffnm $base_path/$name/md -nb gpu -bonded gpu -pme gpu -ntmpi 1

print(f"✅ Completed {pdb_name}\n")

echo "✅ Completed: $name"
