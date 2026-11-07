#!/bin/bash
#PBS -N PMEMD
#PBS -l nodes=1:ncpus=10
#PBS -l walltime=48:00:00
#PBS -q Gpu4-40g
#PBS -o host.out
#PBS -e host_err

module load amber
module load cuda

#Working dir
BASE_PATH="/storage/home/max/protein_complex/Amber/"

pmemd_path="/storage/software/amber/bin/"
cd "$BASE_PATH"


CUDA_VISIBLE_DEVICES=MIG-eaefa1a1-xxxxxxxxxxxxxxxxxxxxxxxxxx  $pmemd_path/pmemd.cuda -O -i minimisation_stage1.in -o minimisation_stage1.out -p protein_complex.parm7 -c protein_complex.rst7  -ref protein_complex.rst7 -r minimisation_stage1.ncrst -inf minimisation_stage1.mdinfo 

CUDA_VISIBLE_DEVICES=MIG-eaefa1a1-xxxxxxxxxxxxxxxxxxxxxxxxxx  $pmemd_path/pmemd.cuda -O -i minimisation_stage2.in -o minimisation_stage2.out -p protein_complex.parm7 -c minimisation_stage1.ncrst  -ref protein_complex.rst7 -r minimisation_stage2.ncrst -inf minimisation_stage2.mdinfo 

CUDA_VISIBLE_DEVICES=MIG-eaefa1a1-xxxxxxxxxxxxxxxxxxxxxxxxxx  $pmemd_path/pmemd.cuda -O -i restrained_heating.in -o restrained_heating.out -p protein_complex.parm7 -c minimisation_stage2.ncrst  -ref protein_complex.rst7 -r restrained_heating.ncrst -x restrained_heating.nc -inf restrained_heating.mdinfo 

CUDA_VISIBLE_DEVICES=MIG-eaefa1a1-xxxxxxxxxxxxxxxxxxxxxxxxxx  $pmemd_path/pmemd.cuda -O -i solvent_equilibration.in -o solvent_equilibration.out -p protein_complex.parm7 -c restrained_heating.ncrst  -ref restrained_heating.ncrst -r solvent_equilibration.ncrst -x solvent_equilibration.nc -inf solvent_equilibration.mdinfo

CUDA_VISIBLE_DEVICES=MIG-eaefa1a1-xxxxxxxxxxxxxxxxxxxxxxxxxx  $pmemd_path/pmemd.cuda -O -i equilibration_stage1.in -o equilibration_stage1.out -p protein_complex.parm7 -c solvent_equilibration.ncrst  -ref restrained_heating.ncrst -r equilibration_stage1.ncrst -x equilibration_stage1.nc -inf equilibration_stage1.mdinfo

CUDA_VISIBLE_DEVICES=MIG-eaefa1a1-xxxxxxxxxxxxxxxxxxxxxxxxxx  $pmemd_path/pmemd.cuda -O -i equilibration_stage2.in -o equilibration_stage2.out -p protein_complex.parm7 -c equilibration_stage1.ncrst  -ref restrained_heating.ncrst -r equilibration_stage2.ncrst -x equilibration_stage2.nc -inf equilibration_stage2.mdinfo 

CUDA_VISIBLE_DEVICES=MIG-eaefa1a1-xxxxxxxxxxxxxxxxxxxxxxxxxx  $pmemd_path/pmemd.cuda -O -i equilibration_stage3.in -o equilibration_stage3.out -p protein_complex.parm7 -c equilibration_stage2.ncrst -r equilibration_stage3.ncrst -x equilibration_stage3.nc -inf equilibration_stage3.mdinfo 

CUDA_VISIBLE_DEVICES=MIG-eaefa1a1-xxxxxxxxxxxxxxxxxxxxxxxxxx  $pmemd_path/pmemd.cuda -O -i production.in -o production.out -p protein_complex.parm7 -c equilibration_stage3.ncrst -r production.ncrst -x production.nc -inf production.mdinfo 
