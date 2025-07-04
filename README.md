# Sprinkler Evapotranspiration MATLAB Tools

This repository implements the Frost & Schwalen nomograph for estimating water loss due to evaporation during sprinkler irrigation.

---

## Files

* **VisNomograph.m**
  Computes evaporation loss *and* produces a visualization of the nomograph with construction lines.

* **solveNomograph.m**
  Computes evaporation loss numerically (no plotting).

---

## Usage

1. Clone or download the repo.

2. Add it to your MATLAB path.

3. Run either function (they use hard‐coded example inputs; edit the `inputs` struct at the top to suit your conditions):

   ```matlab
   evaporationLoss = solveNomograph();
   % or
   evaporationLoss = VisNomograph();
   ```

4. Inspect the console output (and plot, for `VisNomograph`).

---

## Inputs

Both functions use the same `inputs` struct fields:

* `vpd`: Vapor‐Pressure Deficit (psi)
* `nozzle`: Nozzle diameter (in 64ths of an inch)
* `pressure`: Nozzle pressure (psi)
* `wind`: Wind velocity (mph)

Modify these values in the first few lines of each function.

---

## Nomograph Source

Frost, K. R., & Schwalen, H. C. (1960). *Evapotranspiration during sprinkler irrigation.* Transactions of the ASAE, 3(1), 18–20. [https://doi.org/10.13031/2013.41072](https://doi.org/10.13031/2013.41072)

---

## Disclaimer

This software is provided **"as is"** without any express or implied warranty. The author and publisher disclaim all warranties, including but not limited to merchantability and fitness for a particular purpose.

## No Warranty

In no event shall the author or publisher be liable for any claim, damages, or other liability arising from the use of this software.
