# Sprinkler Evapotranspiration MATLAB Tools

This repository provides a MATLAB-based implementation of the Frost & Schwalen nomograph, which estimates evaporation losses during sprinkler irrigation. The tools included allow both numerical and graphical methods to calculate and visualize water loss due to evapotranspiration.

---

## 📁 Files Included

### `main.m`

This is the primary script for visually solving the nomograph. It:

* Accepts hard-coded inputs
* Computes the percent evaporation loss
* Plots the nomograph with construction lines and points
* Saves the visualization as an image file (`nomograph_visualization.png`)

### `solveNomograph.m`

This function provides a numerical-only method (no visualization) for calculating evaporation loss.

---

## 📊 Visualization Example

The following image illustrates how the nomograph is used to estimate evaporation loss based on your specified conditions:

![Nomograph Visualization](nomograph_visualization.png)

---

## 🛠️ How to Use

### 1. Setup

* Clone or download this repository.
* Add the folder to your MATLAB path.

### 2. Choose a script to run:

* **Numerical method:**

  ```matlab
  evaporationLoss = solveNomograph();
  ```
* **Graphical method:**

  ```matlab
  run('main.m');
  ```

### 3. Customize Inputs

Both scripts use an `inputs` structure at the top with the following fields:

| Field      | Description            | Units            |
| ---------- | ---------------------- | ---------------- |
| `vpd`      | Vapor-pressure deficit | psi              |
| `nozzle`   | Nozzle diameter        | 64ths of an inch |
| `pressure` | Nozzle pressure        | psi              |
| `wind`     | Wind velocity          | mph              |

Modify these values to match your real-world conditions.

### 4. Review Results

* **Console Output:** Displays calculated values and intermediate Y-coordinates.
* **Figure Window (`main.m` only):** Shows the nomograph with your input data visualized.
* **Saved Image:** `nomograph_visualization.png` is saved in the working directory.

---

## 📖 Nomograph Source

Frost, K. R., & Schwalen, H. C. (1960). *Evapotranspiration during sprinkler irrigation.*
Transactions of the ASAE, 3(1), 18–20.
DOI: [https://doi.org/10.13031/2013.41072](https://doi.org/10.13031/2013.41072)

---

## ⚠️ Disclaimer

This software is provided **"as is"** without any express or implied warranties. The author and publisher disclaim all warranties, including but not limited to merchantability and fitness for a particular purpose.

## 🚫 No Warranty

In no event shall the author or publisher be liable for any claim, damages, or other liability arising from the use of this software.
