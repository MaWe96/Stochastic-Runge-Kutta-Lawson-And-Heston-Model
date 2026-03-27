# Stochastic Runge-Kutta Lawson Schemes Applied to the Heston Model.

This repository contains the MATLAB implementation and results for my bachelor thesis, which investigates Stochastic Runge-Kutta Lawson (SRKL) schemes and their application to the Heston model.

## 1. Key topics:
- SRKL Schemes: Two SRKL discretization methods (Euler–Maruyama and Midpoint) are used to simulate asset dynamics under the Heston model.
- Option Pricing: European and Asian options are priced using Monte Carlo simulations and variance reduction techniques.
- Comparison: The performance of SRKL methods is compared to benchmark values based on accuracy, effectiveness, and computational complexity.
- Visualizations: Algorithms, simulations, heat maps, step size convergences.
- Appendix: MATLAB code and mathematical formulation of SKRL-applied Heston model.

## 2. Key results:
The study demonstrates that SRKL Euler–Maruyama schemes show promise in improving pricing for both simple and path-dependent options, offering advantages for option valuation in stochastic volatility models like the Heston model.

- Midpoint: Under-pricing of call options.
- Midpoint: Less efficient than traditional methods.
- Euler: More accurate and efficient than Midpoint.
- Consistent no matter the step size.
**Encountered Issues:**
- Hard to implement.
- Unstable results.
**Further research:**
- FSL and DSL schemes comparison.
- Other derivatives, numerical methods, and models.
- Model fitting and portfolios.

### 2.1 Implementation
![Algorithm 2](https://github.com/MaWe96/Stochastic-Runge-Kutta-Lawson-And-Heston-Model/blob/main/Results/Algorithm%202.png)

### 2.2 Heat map
![Result 1](https://github.com/MaWe96/Stochastic-Runge-Kutta-Lawson-And-Heston-Model/blob/main/Results/Result%201.png)

### 2.3 Convergences
![Result 2](https://github.com/MaWe96/Stochastic-Runge-Kutta-Lawson-And-Heston-Model/blob/main/Results/Result%202.png)

### 2.4 EU Call: Price, error & efficiency
![Result 3](https://github.com/MaWe96/Stochastic-Runge-Kutta-Lawson-And-Heston-Model/blob/main/Results/Result%203.png)

### 2.5 Arithmetic & Geometric Asian Call: Price, error & efficiency
![Result 4](https://github.com/MaWe96/Stochastic-Runge-Kutta-Lawson-And-Heston-Model/blob/main/Results/Result%204.png)
