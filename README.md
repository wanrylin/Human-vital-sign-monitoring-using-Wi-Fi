# Human vital sign monitoring using Wi-Fi 2021
Part of work in this project has been published: https://ieeexplore.ieee.org/abstract/document/9790274 <br>
My Final Year Project (FYP) is done with the cooperation of Lindy Zhou homepage:https://github.com/LINDYZHOU.  
Our superviser is Prof.Cuo Yongxin homepage:https://www.ece.nus.edu.sg/stfpage/eleguoyx/.

## Introduction
Due to the aging tendency and COVID-19 all over the world, the demand of non-contact vital sign monitoring is becoming more and more important. Compared to radar or high-quality camera, Wi-Fi devices are off-the-shelf, universal and low-cost. Therefore, great contribution has been made by the researchers all over the world on vital sign monitoring using Wi-Fi recently.<br>
This project proposes a new system based on Wi-Fi CSI data. In the contrast to the pervious study, I introduce the latest IEEE 802.11ac/ax protocols into the system instead of IEEE 802.11n protocol as the sensing tool. Meanwhile, I extract both CSI amplitude and phase data as the input of the system from the network card. To reach better performance, I design two new subcarrier selection methods, SNR subcarrier selection and SSNR subcarrier selection. Furthermore, a new multi-person detection method is proposed via SSNR, which detection accuracy can be over 96%. The overall accuracy for breathing rate estimation is over 92% and for heart rate estimation is over 84%.

## Main contribution
(1) Apply IEEE 802.11ac/ax protocols into human vital signs monitoring system.<br>
(2) Propose 2 new subcarrier selection method based on SNR and SSNR respectively.<br>
(3) Adopt a multi-person detection method with SSNR and achieve over 96% accuracy.

## Conditions and assumption
In order to make it clear about the situations that this paper is suitable for, some basic conditions are listed as follows:<br>
(1)Wireless transmission protocol of the Wi-Fi device: IEEE 802.11ac/ax.<br>
(2) Operating frequency band: 5GHz<br>
(3) Number of transmitting antennas: 2<br>
(4) Number of receiving antenna: 2<br>
(5) Application senario: indoor LOS<br>
(6) Sampling rate: 200Hz<br>
(7) Posture of subject person: sit/lie

## Overview of the system
![overview of the system](https://github.com/wanrylin/Human-vital-sign-monitoring-using-Wi-Fi/blob/main/figures/system.png)
The captured CSI data contains the amplitude and phase sequence in each subcarrier. This project is an amplitude and phase based system. Two new subcarrier selection methods based on Signal-Noise-Ratio (SNR) and Sensing Signal to Noise Ratio (SSNR) are proposed to select subcarriers sensitive to breath and heartbeat movements respectively. Two Wavelet transforms are utilized to extract the breath signal and heartbeat signal respectively. A multi-person detection algorithm is proposed to distinguish multi-person scenario from signal-person scenario based on SSNR.

## System Design
### 1 CSI capturing
This system is implemented with off-the-shelf hardware devices. 2 PCs are used as the sending and receiving devices, and their network card for each is Intel Ax200 with 2 omni antennas which supports the latest IEEE 802.11ac/ax protocols. The PCs have Ubuntu OS in version 20.04. I use the PicoScenes CSI-toolbox [^1], which is a Wi-Fi sensing platform software that supports the 802.11ac/ax-format CSI measurement, to extract CSI data from received Wi-Fi signals. The received CSI data contains CSI amplitude and phase information as well as the index of the package which is utilized in interpolation. The CSI captured by PicoScenes platform is progressed in Matlab 2021b with PicoScenes toolbox.

### 2 Subcarrier selection
IEEE 802.11ac/ax contains much more subcarriers than 802.11n, up to 4times in our experiment. This new feature makes it possible to dynamically select subcarriers with the best performance. Meanwhile, the pervious method performs weak after applied into our experiment. Therefore, it is necessary to design a new subcarrier selection method.<br>
Generally speaking, there are 2 main features of subcarriers.  <br>
(1)The sensibility of every subcarrier is different.  <br>
(2)The sensibility of one subcarrier fluctuates as time goes by.<br>
<img src="https://github.com/wanrylin/Human-vital-sign-monitoring-using-Wi-Fi/blob/main/figures/subcarrier%20feature.png" alt="subcarrier feature" width="500"><br>
As the figure shows, the 122th subcarrier is most sensitive in the first few seconds while the 145th subcarrier is most sensitive around 25 seconds. Therefore, deriving the result only from one subcarrier is obviously unreliable. It is feasible and necessary to draw the result from a serious of subcarriers. <br>
According to paper[^2], in one Fresnel zone model, if there is one subcarrier is affected by respiration, there must be other affected subcarriers. Meanwhile, both breathing and heartbeat is most obvious on the chest. So according to Fresnel Zone Model, the subcarriers selected for breathing estimation and heartrate estimation should be the same.[^3] Due to the movement of breathing is much fiercer than heartbeat, the subcarrier selection is focus on breathing.

#### SNR based subcarrier selection
SNR is widely utilized in communication signal analysis. It is adapted to applied into human vital sign by us. The adapted SNR is able to qualify the sensing ability of subcarrier in a limited frequency range. It can be represented as below:<br>
<img src="https://github.com/wanrylin/Human-vital-sign-monitoring-using-Wi-Fi/blob/main/figures/fomula1.png" alt="fomula 1" width="400"><br>
where the frequency range is from $`f_1`$ to $f_2$. $P_{i,max}$ is the power of maximum frequency component, and $P_n$ is the power of noise. In the experiment, $P_n$ can be calculated as the average power. For human vital sign monitoring, like respiration, the frequency range can be set from 0Hz to 0.6Hz.
After pre-processing and removing the DC component, the signals are transformed into the frequency domain. Then the SNR of every subcarrier is calculated. The threshold of SNR is 10dB. If there is any SNR of one subcarrier higher than the threshold, this subcarrier is selected.To reduce the interference, the minimum of the subcarriers selected is set to 3. If there is less than 3 subcarriers selected, with the threshold, the threshold will be declined by 5% and redo the selection.

#### SSNR based subcarrier selection
The CSI can be represented as a linear superposition of all the paths including the dynamic path $H_d\left(f,t\right)\$ static path $H_s\left(f,t\right)\$ and noise $H_n\left(f,t\right)$:<br>
$$H\left(f,t\right)= H_d\left(f,t\right)+ H_s\left(f,t\right)+ H_n\left(f,t\right) $$
Different from communication, in Wi-Fi sensing, only the dynamic signals reflected from the target contain the sensing information. Static signals such as the LOS signal and reflections from walls do not contain target information and therefore can not contribute to sensing. Therefore, it is not appropriate to use the SNR designed for communication to characterize the sensing capability. What is interesting is that in Wi-Fi sensing, in addition to thermal noise which influences the extraction of the dynamic signal for sensing, the static signal also has a negative effect on sensing. SSNR (sensing-signal-to-noise-ratio) is proposed to quantify the sensing capability. It is utilized to detect the boundary of the sensing in research[^4]. I introduce this concept into subcarrier analysis. SSNR can be represented as below:<br>
$$SSNR=\frac{P_d}{P_i}=\frac{{|H_d\left(f,t\right)|}^2}{{|g\left(H_s\left(f,t\right)\right)+H_n\left(f,t\right)+H_i\left(f,t\right)|}^2} $$
where $P_d$ is the power of the dynamic signal reflected from target, and $P_i$ contains the thermal noise ${H_n\left(f,t\right)}^2$, the effect of other dynamic subjects, i.e., interferers $(H_i\left(f,t\right))$, and also interference $(g\left(H_s\left(f,t\right)\right))\$ induced by the static signal $(H_s\left(f,t\right))$. In the experiment, the static signal power can be calculated as the average CSI amplitude(phase). The maximum value of the difference between the CSI amplitude(phase) and the averaged amplitude(phase) indicates the dynamic power. The interference power is calculated as the difference before and after hampel filtering the CSI amplitude(phase).<br>
<img src="https://github.com/wanrylin/Human-vital-sign-monitoring-using-Wi-Fi/blob/main/figures/SSNR.png" alt="SSNR subcarrier selection" width="600"><br>
Form the figure, it is obvious that the SSNR of every subcarrier is differs a lot. Therefore, it is important to select the subcarriers with maximum SSNR. In SSNR-based subcarrier selection, the 10 subcarriers with the biggest SSNR are selected and sent to the next process.

### Multi-person detection
According to the research[^5], there is 2 features of CSI phase data.<br>
(1) The CSI phase consists of static component and dynamic component.<br>
(2) The dynamic component is periodic with the dynamic source in the scenario.<br>
From (1) and (2), if there is only one dynamic source in the scenario, the CSI phase of subcarrier can be represented as:<br>
For the nth subcarrier: 
$${H\left(f,t\right)}_n= {H_d\left(f,t\right)}_n+{H_s\left(f,t\right)}_n+{H_n\left(f,t\right)}_n
                                                    = {kH_d\left(f,t\right)}_1+b{H_s\left(f,t\right)}_1+ {H_n\left(f,t\right)}_1$$
Then when utilizing SSNR calculates the sensing ability of the subcarriers, a number of subcarriers with the highest SSNR in a frame can be selected. After SSNR subcarrier selection, we can consider that ${|H}_d\left(f,t\right)\left|\gg{|H}_n\left(f,t\right)\right|$. If so, the upper formula can be represented as:
$${H\left(f,t\right)}_n={kH_d\left(f,t\right)}_1+b{H_s\left(f,t\right)}_1+ {H_n\left(f,t\right)}_1
                                          \approx k^\prime{H\left(f,t\right)}_1+c $$
According to this formula, there is a linear dependence between the subcarriers, which means the correlation between subcarriers should be close to 1, when there is only one person under monitoring. On the contrast, if there is more than one person under monitoring, the linear dependence between subcarriers is dramatically weaken and the correlation should be much smaller than the single-person situation.<br>
Applying SSNR subcarrier selection into the system, and find top 20 subcarriers with the highest SSNR under IEEE 802.11ax protocol. Calculate the correlation coefficient between subcarriers in time domain and obtain the average value of the correlation coefficient matrix. The result is shown here:<br>
<img src="https://github.com/wanrylin/Human-vital-sign-monitoring-using-Wi-Fi/blob/main/figures/multiperson.png" alt="SSNR subcarrier selection" width="600"><br>
It is obvious that, the correlation of multi-person scenarios is always lower than 0.9 and the correlation of single-person scenarios is always over 0.9. The result of experiment matches the theory successfully. The threshold is set as 0.9, to detect whether it is multi-person situation. In the system, if constant 2 frames are detected the correlation is over 0.9, the system will recognize current situation is multi-person. The overall accuracy is 96.9% derived from the experiment.

### Wavelet transform
Different from FFT and short-time Fourier transform (STFT), Wavelet Transform can achieve a time-frequency representation of data, which provides not only the optimal resolution both in the time and frequency domains but also a multiscale analysis of the data. With Wavelet Transform, the phase difference data after subcarrier selection can be decomposed into an approximation coefficient vector with a low-pass filter and a detail coefficient vector with a high-pass filter. In fact, the approximation coefficient vector represents the basic shape of the input signal with large-scale characteristics, whereas the detail coefficient vector describes the high-frequency noises and the detailed information with small-scale characteristics. 

In my system, Wavelet Transform is utilized to remove high-frequency noises from the collected CSI data. Moreover, the approximation coefficient $\alpha^L$  is used to detect the breathing rate and the sum of detail coefficients $\beta^{L-1}+\ \beta^L$ is used to detect the heart rate and the L is set to 4. For the original signal, I first execute the DWT-based decomposition recursively for four levels with the Daubechies (db) wavelet filter. After downsampling, the sampling rate becomes 20 Hz. Then the sampling rate is halved after every step of Wavelet Transform decomposition, and the detail coefficient $\beta^1$ and the approximation coefficient $\alpha^1$ have a frequency ranging from 10 to 5 Hz and 0 to 5 Hz, respectively.  

For breath rate esitmation, after four decomposition steps, the approximation coefficient $\alpha^4$ is in the range of 0 to 0.625 Hz, which is used to obtain the denoised breathing signal. I use different coefficients based on the frequency of the main component $(𝑓_1)$ of each subcarrier. 
If $𝑓_1$ is higher than 0.3 Hz, it is called Fast Breath and only the 5th detailed coefficient is used.  If $𝑓_1$ is lower than 0.3 Hz, it is called Slow Breath and only the 6th detailed coefficient is used. Then a clear respiratory signal can be re-constructed by doing inverse DWT.
For heartbeat rate estimation, The sum of detail coefficients $\beta^3+\ \beta^4$ covers frequencies from 0.625 to 2.5 Hz, which is used to reconstruct the heart signal.

## Result and conclusion
#### Evaluation metric
The ground truths of vital signs are monitored by a breath belt and 2 oximeters. Denote the estimated value of breathing or heart rate as $f_e$, the ground truth as $f_g$. The estimation accuracy $A_e$ is denoted as the equation:
$$A_e = \left(1 - \frac{|f_e - f_g|}{f_g}\right) \times 100 \\% $$
The performance of the system is evaluated by the estimation accuracy.

#### Result
This project has applied different CSI data features while extracting the respiratory signal. The performance of breathing rate estimation under IEEE 802.11ac/ax  is evaluated. The overall accuracy is shown in the table, and all the accuracy is calculated based on the dataset from our experiment.<br>
**The accuracy of breathing rate estimation[^6][^7][^8]**
<table style="text-align:center">
  <tr>
    <th>Subcarrier selection method</th>
    <th colspan="3">SNR subcarrier selection</th>
    <th>Largest variance</th>
    <th>SNR subcarrier selection</th>
  </tr>
  <tr>
    <td><b>CSI feature</b></td>
    <td>Phase difference</td>
    <td>Amplitude</td>
    <td>Phase</td>
    <td>Amplitude</td>
    <td>Amplitude</td>
  </tr>
  <tr>
    <td><b>Denoising method</b></td>
    <td colspan="4">Fast/Slow wavelet transform</td>
    <td>Band-pass Filter</td>
  </tr>
  <tr>
    <td><b>Accuracy</b></td>
    <td><b>92.17%</b></td>
    <td>86.25%</td>
    <td>79.49%</td>
    <td>71.9%</td>
    <td>83.95%</td>
  </tr>
</table>

**The accuracy of heart rate estimation**
<table style="text-align:center">
  <tr>
    <th>CSI</th>
    <th colspan="2">Amplitude</th>
    <th colspan="2">Phase difference</th>
    <th>Average</th>
  </tr>
  <tr>
    <td><b>Subcarrier selection method</b></td>
    <td>SNR</td>
    <td>SSNR</td>
    <td>SNR</td>
    <td>SSNR</td>
    <td></td>
  </tr>
  <tr>
    <td><b>Average value</b></td>
    <td>84.28%</td>
    <td>84.01%</td>
    <td>82.02%</td>
    <td>85.19%</td>
    <td>83.875%</td>
  </tr>
  <tr>
    <td><b>Maximun SNR value</b></td>
    <td>85.80%</td>
    <td>82.71%</td>
    <td>84.65%</td>
    <td>85.26%</td>
    <td>84.605%</td>
  </tr>
   <tr>
    <td><b>Average</b></td>
    <td colspan="2">84.2%</td>
    <td colspan="2">84.28%</td>
    <td></td>
  </tr>
</table>























## Reference
[^1]:Z. Jiang, T. H. Luan, X. Ren, D. Lv, H. Hao, J. Wang, K. Zhao, W. Xi, Y. Xu, and R. Li, “Eliminating the Barriers: Demystifying Wi-Fi Baseband Design and Introducing the PicoScenes Wi-Fi Sensing Platform,” IEEE Internet of Things Journal, pp. 1-1, 2021.
[^2]:X. Wang et al., "Placement Matters: Understanding the Effects of Device Placement for WiFi Sensing," vol. 6, no. 1 Proc. ACM Interact. Mob. Wearable Ubiquitous Technol., p. Article 32, 2022.
[^3]:H.Wang et al., "Human respiration detection with commodity wifi devices: do user location and body orientation matter?," presented at the Proceedings of the 2016 ACM International Joint Conference on Pervasive and Ubiquitous Computing, Heidelberg, Germany, 2016.
[^4]:X. Wang et al., "Placement Matters: Understanding the Effects of Device Placement for WiFi Sensing," vol. 6, no. 1 Proc. ACM Interact. Mob. Wearable Ubiquitous Technol., p. Article 32, 2022.
[^5]:X. Wang, C. Yang, and S. J. A. T. o. C. f. H. Mao, "On CSI-based vital sign monitoring using commodity WiFi," vol. 1, no. 3, pp. 1-27, 2020
[^6]:Y. Gu, X. Zhang, Z. Liu, and F. Ren, WiFi-Based Real-Time Breathing and Heart Rate Monitoring during Sleep. 2019, pp. 1-6.
[^7]:S. Lee, Y. Park, Y. Suh, and S. Jeon, "Design and implementation of monitoring system for breathing and heart rate pattern using WiFi signals," in 2018 15th IEEE Annual Consumer Communications & Networking Conference (CCNC), 2018, pp. 1-7.
[^8]:N. Bao et al., "The Intelligent Monitoring for the Elderly Based on WiFi Signals," Cham, 2018, pp. 883-892: Springer International Publishing.
