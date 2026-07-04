# DC Motor Speed Control with PID Controller
### MATLAB/Simulink | Simscape | Control Systems

A complete separately-excited DC motor simulation built from first principles,
featuring closed-loop PID speed control, a physical Simscape rebuild, 
and an automated motor characterization and load analysis script.

---

## Project Overview

This project models a separately-excited DC motor starting from its two 
governing differential equations, implements a PID controller to regulate 
speed, and provides a characterization script that automatically tests motor 
performance across five different load conditions.

The project was built in three stages:

### Stage 1 — Math-Block Model (DCCONTROL.slx)
The motor's electrical and mechanical equations were derived by hand and 
implemented directly in Simulink using Sum, Gain, and Integrator blocks:

**Electrical equation:**
$$\frac{dI_a}{dt} = \frac{V - E_b - I_a R_a}{L_a}$$

**Mechanical equation:**
$$\frac{d\omega}{dt} = \frac{T - B\omega - T_L}{J}$$

The open-loop model was first verified against hand-calculated steady-state 
values, then a PID controller was added to close the loop and regulate speed 
to a user-defined reference.

Key findings:
- Motor overload case (TL > T_stall) correctly produces negative speed — 
  verified against hand-calculated values
- PI control (Kp=75, Ki=25) achieves target speed within engineering tolerance 
  (~0.9% steady-state error)

### Stage 2 — Simscape Physical Model (DCCONTROL_INDOMAIN.slx)
The same motor was rebuilt using real physical components:
- **Electrical domain:** Resistor (Ra), Inductor (La), Controlled Voltage 
  Sources (V, Eb), Current Sensor
- **Mechanical domain:** Inertia (J), Rotational Damper (B), Ideal Torque 
  Sources (motor torque and load torque), Rotational Motion Sensor
- **Domain bridging:** PS-Simulink Converters with Kt and Kb gain blocks 
  connecting the two physical networks

Retuned PID gains (Kp=3, Ki=2, Kd=1) validated against the math-block model.

### Stage 3 — Motor Characterization Script (scriptforDCCONTROL_INDOMAIN.m)
A MATLAB script that takes motor parameters as input and automatically:
1. Calculates motor potential (stall torque, no-load speed, time constants)
2. Suggests PID gains scaled from motor time constants
3. Generates 5 load test cases between 0 and stall torque
4. Runs each simulation and reports theoretical vs actual speed, 
   percentage error, and settling time

Notable result: at 83% of stall torque (TL = 0.125 N·m), the script reported 
308% error — not a bug, but the PID gains optimized for light-load conditions 
becoming unstable near the motor's physical limits. A practical demonstration 
that a controller tuned for one operating range isn't guaranteed to work across 
all conditions.

---

## Motor Parameters Used

| Parameter | Symbol | Value | Unit |
|-----------|--------|-------|------|
| Armature Resistance | Ra | 1 | Ω |
| Armature Inductance | La | 0.5 | H |
| Rotor Inertia | J | 0.01 | kg·m² |
| Friction Coefficient | B | 0.1 | N·m·s |
| Torque Constant | Kt | 0.01 | N·m/A |
| Back-EMF Constant | Kb | 0.01 | V·s/rad |
| Supply Voltage | V | 15 | V |
| Reference Speed | ω_ref | 0.9 | rad/s |

---

## Files

| File | Description |
|------|-------------|
| `DCCONTROL.slx` | Math-block Simulink model (Stage 1) |
| `DCCONTROL_INDOMAIN.slx` | Simscape physical model (Stage 2) |
| `scriptforDCCONTROL_INDOMAIN.m` | Motor characterization script (Stage 3) |

---

## How to Run

1. Clone or download the repository
2. Open MATLAB (R2021a or later recommended)
3. Make sure all three files are in the same folder
4. Open `scriptforDCCONTROL_INDOMAIN.m`
5. Uncomment the `input()` lines to enter custom motor parameters, 
   or run as-is with the default values
6. Run the script — it will automatically load the Simscape model, 
   run 5 load tests, display the results table, and plot all responses

**Requirements:** MATLAB, Simulink, Simscape, Simscape Electrical, 
Simscape Multibody

---

## Results

### Terminal Output
<img width="1062" height="504" alt="Screenshot 2026-07-03 181019" src="https://github.com/user-attachments/assets/4c7f325d-eed0-4357-846c-a3f7a9ee68ca" />


### Multi-curve Load Response Plot
<img width="1075" height="668" alt="image" src="https://github.com/user-attachments/assets/91a0e47a-ce09-40c6-9cae-bf6553756e37" />


---

## Key Learnings

- The back-EMF feedback loop inside a DC motor is itself a natural 
  proportional controller — it self-regulates speed, but always with 
  a residual steady-state error that an external PID is needed to eliminate
- P-only control reaches steady state reliably but always undershoots 
  the target under load — the I-term is specifically needed to close that gap
- PID gains are model-specific — gains tuned for the math-block model 
  required retuning for the Simscape model despite identical motor parameters
- Auto-tuning from motor parameters alone has fundamental limitations — 
  simulation-based validation is always needed

---

## Author

**Yash Rajendra Koli**  
SY B.Tech Electrical Engineering  
Walchand College of Engineering, Sangli  
[LinkedIn](https://www.linkedin.com/in/yash-koli-776509368/) | [GitHub](https://github.com/Koliheroyash)
