# Essentials of CORDIC

## 1. The Math

In all formulas in these article:

$$
m = 
\begin{cases}
1, & \text{for Circular Coordinates} \\
0, & \text{for Linear Coordinates} \\
-1, & \text{for Hyperbolic Coordinates}
\end{cases}
$$

And:

$$
\sigma_j = 
\begin{cases}
\mathrm{sign}^+(z[j]), & \text{for Rotation Mode} \\
-\mathrm{sign}^+(y[j]), & \text{for Vectoring Mode}
\end{cases}
$$

### 1.1. Iteration Steps

Iteration steps are *pseudo rotation* steps,
*pseudo rotation* is a kind of rotation with correct rotation angle
and *scaled* vector length.

$$
\begin{cases}
x[j+1] = x[j] - m \sigma_j 2^{-j}y[j] \\
y[j+1] = y[j] + \sigma_j 2^{-j}x[j] \\
z[j+1] = z[j] - m^{-1/2} \sigma_j \tan^{-1}(m^{1/2} 2^{-j}) \\
k_m[j] = \sqrt{1+m\cdot2^{-2j}}
\end{cases}
$$

In which: $k_m[j]$ is the vector(x and y) scaling factor of pseudo rotation.

Notice that: $z[j+1]|_{m\to0}=z[j]-\sigma_j(2^{-j})$

### 1.2. Initial and Result

#### 1.2.1. Circular

$$
\begin{cases}
j = 0, 1, 2, ..., n \\
k_{1,n} = \prod_j k_1[j] = \prod_j \sqrt{1+2^{-2j}} \\
k_1 := k_{1,\infty} \approx 1.64676025812 \\
\left|z\right|_{\text{max},n}=\sum_j\tan^{-1}(2^{-j}) \\
z_\text{max} :=\left|z\right|_{\text{max},\infty}\approx1.74328662047\approx99.882965835\deg
\end{cases}
$$

Rotation Mode Result:

$$
\begin{cases}
x_\infty = k_1 \left(x_0 \cos(z_0) - y_0 \sin(z_0) \right) \\
y_\infty = k_1 \left(x_0 \sin(z_0) + y_0 \cos(z_0) \right) \\
z_\infty = 0
\end{cases}
$$

Vectoring Mode Result:

$$
\begin{cases}
x_\infty = k_1 \sqrt{x_0^2 + y_0^2} \\
y_\infty = 0 \\
z_\infty = z_0 + \tan^{-1} \left(\frac{y_0}{x_0}\right)
\end{cases}
$$

#### 1.2.2. Linear

$$
\begin{cases}
j = 0, 1, 2, ..., n \\
k_0 := k_{0,\infty} = 1 \\
\left|z\right|_{\text{max},n}=\sum_j2^{-j} = 2-2^{-n}\\
z_\text{max} :=\left|z\right|_{\text{max},\infty} = 2
\end{cases}
$$

Rotation Mode Result:

$$
\begin{cases}
x_\infty = x_0 \\
y_\infty = y_0 + x_0 \cdot z_0 \\
z_\infty = 0
\end{cases}
$$

Vectoring Mode Result:

$$
\begin{cases}
x_\infty = x_0 \\
y_\infty = 0 \\
z_\infty = z_0 + \frac{y_0}{x_0}
\end{cases}
$$

#### 1.2.3. Hyperbolic

$$
\begin{cases}
j = 1, 2, 3, 4, 4, 5, ..., 12, 13, 13, 14, ..., n \\
k_{-1,n} = \prod_j k_1[j] = \prod_j \sqrt{1-2^{-2j}} \\
k_{-1} := k_{1,\infty} \approx 0.82815936096 \\
\left|z\right|_{\text{max},n}=\sum_j\tanh^{-1}(2^{-j}) \\
z_\text{max} :=\left|z\right|_{\text{max},\infty}\approx1.11817301553
\end{cases}
$$

Rotation Mode Result:

$$
\begin{cases}
x_\infty &= k_{-1} \left( x_1 \cosh(z_1) + y_1 \sinh(z_1) \right) \\
&= \frac{k_{-1}}{2}\left( (x_1 + y_1)e^{z_1} + (x_1 - y_1)e^{-z_1} \right) \\
y_\infty &= k_{-1} \left( x_1 \sinh(z_1) + y_1 \cosh(z_1) \right) \\
&= \frac{k_{-1}}{2}\left( (y_1 + x_1)e^{z_1} + (y_1 - x_1)e^{-z_1} \right) \\
z_\infty &= 0
\end{cases}
$$

Vectoring Mode Result:

$$
\begin{cases}
x_\infty &= k_{-1} \sqrt{x_1^2 - y_1^2} \\
y_\infty &= 0 \\
z_\infty &= z_1 + \tanh^{-1} \left(\frac{y_1}{x_1}\right) \\
&= z_1 + \frac{1}{2} \ln\left( \frac{x_1 + y_1}{x_1 - y_1} \right)
\end{cases}
$$

# 2. What `cordic.scala` implemented

## 2.1. class `CordicStage`

class `CordicStage` implemented single iteration step.

## 2.2. class `CordicCircularQuadrantTrans`

class `CordicCircularQuadrantTrans` implemented quadrant translation for
circular coordinates, which expand angle domain from $\approx \pm 99.883 \deg$
to $\pm \pi$ (full circle).

## 2.3. class `CordicLinearVectoringQuadrantTrans`

class `CordicLinearVectoringQuadrantTrans` implemented quadrant translation
for circular vectoring mode, which expand (x, y) from quadrant 1 & 4 to
quadrant 1~4.

## 2.4. class `CordicHyperbolicVectoringQuadrantTrans`

class `CordicHyperbolicVectoringQuadrantTrans` implemented quadrant translation
for hyperbolic vectoring mode, which expand (x, y) from quadrant 1 & 4 to
quadrant 1~4.

## 2.5. class `Cordic`

class `Cordic` implemented quadrant translation, iteration steps and scale compensation.

### 2.5.1. Circular

#### 2.5.1.1. Rotation Mode

$$
\begin{cases}
x_n \approx x_0 \cos(\pi z_0) - y_0 \sin(\pi z_0) \\
y_n \approx x_0 \sin(\pi z_0) + y_0 \cos(\pi z_0) \\
z_n \approx 0
\end{cases}
$$

Domain of $z$ is [-1, 1), and will be mapped to $[-\pi, \pi)$ internally.

#### 2.5.1.2. Vectoring Mode

$$
\begin{cases}
x_n & \approx \sqrt{x_0^2 + y_0^2} \\
y_n & \approx 0 \\
z_n & \approx \mathrm{wrap}_{[-\pi, \pi)} (z_n') \\
& \text{in which:}\ z_n' = z_0 + \frac{1}{\pi} \mathrm{atan2} \left(y_0, x_0\right)
\end{cases}
$$

Domain of $(x, y)$ is all 4 quadrant.

### 2.5.2. Linear

#### 2.5.2.1. Rotation Mode

$$
\begin{cases}
x_n \approx x_0 \\
y_n \approx y_0 + x_0 \cdot z_0 \\
z_n \approx 0
\end{cases}
$$

Domain of $z$ is $\left[-2^{1-\mathrm{linStgStart}}, 2^{1-\mathrm{linStgStart}}\right)$

#### 2.5.2.2. Vectoring Mode

$$
\begin{cases}
x_n \approx |x_0| \\
y_n \approx 0 \\
z_n \approx z_0 + \frac{y_0}{x_0}
\end{cases}
$$

Domain of $(x,y)$ is all 4 quadrant and
$\frac{y}{x} \in\left[-2^{1-\mathrm{linStgStart}}, 2^{1-\mathrm{linStgStart}}\right)$

and, `xyWidth` and `xyFracWidth` must make range of $|x|$ or $|y|$ covers
$\max \left\{ x_\mathrm{in} 2^\mathrm{-linStgStart}, y_\mathrm{in} 2^\mathrm{-linStgStart}, x_\mathrm{out}, y_\mathrm{out} \right\}$.

### 2.5.3. Hyperbolic

#### 2.5.3.1. Rotation Mode

$$
\begin{cases}
x_n &\approx  x_1 \cosh(z_1) + y_1 \sinh(z_1) \\
&= \frac{1}{2} (x_1 + y_1)e^{z_1} + \frac{1}{2} (x_1 - y_1)e^{-z_1} \\
y_n &\approx  x_1 \sinh(z_1) + y_1 \cosh(z_1) \\
&= \frac{1}{2} (y_1 + x_1)e^{z_1} + \frac{1}{2} (y_1 - x_1)e^{-z_1} \\
z_n &\approx 0
\end{cases}
$$

Domain of $z$ is $\left(-1.11817301553, 1.11817301553\right)$, accordingly:
 - $\cosh(z) \in [1, 1.69306816090)$,
 - $\sinh(z) \in (-1.36619171329, 1.36619171329)$,
 - $e^z \in (0.32687644761, 3.05925987419)$.


#### 2.5.3.2. Vectoring Mode

$$
\begin{cases}
x_n &\approx \sqrt{x_1^2 - y_1^2} \\
y_n &\approx 0 \\
z_n &\approx z_1 + \tanh^{-1} \left(\frac{y_1}{x_1}\right) \\
&= z_1 + \frac{1}{2} \ln\left( \frac{x_1 + y_1}{x_1 - y_1} \right)
\end{cases}
$$

Domain of $(x, y)$ is all 4 quadrant and
$\left|\frac{y}{x}\right| < \tanh(1.11817301553) \approx 0.80693249382$,
accordingly:
 - $\frac{x+y}{x-y} \in (0.10684821200, 9.35907097766)$
 - $\tanh^{-1} \left(\frac{y}{x}\right) = \frac{1}{2} \ln \left( \frac{x+y}{x-y} \right) \in (-1.11817301553, 1.11817301553)$

