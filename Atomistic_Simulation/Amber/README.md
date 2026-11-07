## Running the Molecular Dynamics Simulation

Follow the steps below to generate the topology and coordinate files and run the production simulation.

### 1. Generate Topology and Coordinate Files

Before running the topology generation step, make sure that the **latest version of AmberTools** is installed and properly configured in your Conda environment or local system.

Use the following command to execute the `tleap` input script:

```bash
tleap -f leap.in
```

This command reads `leap.in` and generates the required topology and coordinate files for the molecular dynamics simulation.

### 2. Run the Production Simulation

Before submitting the production job, ensure that all required `.in` input files are present in the working directory and correctly configured.

Unlike GROMACS, which primarily uses `.mdp` files for simulation parameters, AMBER uses `.in` files to define simulation settings.

Submit the production simulation job using:

```bash
qsub pmemd_pbs.sh
```

This command submits the production simulation to the PBS job scheduler using the `pmemd_pbs.sh` script.

### 1. Notes

- Ensure AmberTools is installed and accessible through your environment.
- Verify that `leap.in` contains the correct topology and coordinate generation settings.
- Check that all required AMBER input files (`.in`) are available before submitting the production job.
- Make sure `pmemd_pbs.sh` is configured with the correct executable, file paths, resource requirements, and input/output filenames.
- Monitor the PBS job status and check the output files for successful completion.


### 2. Additional Files Provided

- The ATP ligand topology and parameter files are provided:
  - `atp.mol2` – Contains the ATP molecular structure and atom types/charges.
  - `atp.frcmod` – Contains additional force-field parameters for ATP.
  - `frcmod.mgnew` – Contains additional force-field parameters for Mg²⁺.

- Make sure these files are loaded appropriately in `leap.in` during topology and coordinate generation.
