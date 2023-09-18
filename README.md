# Human vital sign monitoring using Wi-Fi 2021
Part of work in this project has been published: https://ieeexplore.ieee.org/abstract/document/9790274
My Final Year Project (FYP) cooperated with @github/Lindy Zhou homepage:https://github.com/LINDYZHOU.  
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
This system is implemented with off-the-shelf hardware devices. 2 PCs are used as the sending and receiving devices, and their network card for each is Intel Ax200 with 2 omni antennas which supports the latest IEEE 802.11ac/ax protocols. The PCs have Ubuntu OS in version 20.04. I use the PicoScenes CSI-toolbox [1], which is a Wi-Fi sensing platform software that supports the 802.11ac/ax-format CSI measurement, to extract CSI data from received Wi-Fi signals. The received CSI data contains CSI amplitude and phase information as well as the index of the package which is utilized in interpolation. The CSI captured by PicoScenes platform is progressed in Matlab 2021b with PicoScenes toolbox.

### 2 Subcarrier selection
IEEE 802.11ac/ax contains much more subcarriers than 802.11n, up to 4times in our experiment. This new feature makes it possible to dynamically select subcarriers with the best performance. Meanwhile, the pervious method performs weak after applied into our experiment. Therefore, it is necessary to design a new subcarrier selection method.<br>
Generally speaking, there are 2 main features of subcarriers.  <br>
(1)The sensibility of every subcarrier is different.  <br>
(2)The sensibility of one subcarrier fluctuates as time goes by.<br>
<img src="https://github.com/wanrylin/Human-vital-sign-monitoring-using-Wi-Fi/blob/main/figures/subcarrier%20feature.png" alt="subcarrier feature" width="500"><br>
As the figure shows, the 122th subcarrier is most sensitive in the first few seconds while the 145th subcarrier is most sensitive around 25 seconds. Therefore, deriving the result only from one subcarrier is obviously unreliable. It is feasible and necessary to draw the result from a serious of subcarriers. <br>
According to paper[2], in one Fresnel zone model, if there is one subcarrier is affected by respiration, there must be other affected subcarriers. Meanwhile, both breathing and heartbeat is most obvious on the chest. So according to Fresnel Zone Model, the subcarriers selected for breathing estimation and heartrate estimation should be the same.[3] Due to the movement of breathing is much fiercer than heartbeat, the subcarrier selection is focus on breathing.

#### SNR based subcarrier selection
SNR is widely utilized in communication signal analysis. It is adapted to applied into human vital sign by us. The adapted SNR is able to qualify the sensing ability of subcarrier in a limited frequency range. It can be represented as below:
$$ SNR_{m,i} = \frac{P_{i,max}}{P_n} = \frac{S_{i,max}}{\frac{1}{t}\cdot\sum_{f_2}^{m=f_1}S_{i,m} $$




## Reference
[1]Z. Jiang, T. H. Luan, X. Ren, D. Lv, H. Hao, J. Wang, K. Zhao, W. Xi, Y. Xu, and R. Li, “Eliminating the Barriers: Demystifying Wi-Fi Baseband Design and Introducing the PicoScenes Wi-Fi Sensing Platform,” IEEE Internet of Things Journal, pp. 1-1, 2021.<br>
[2]X. Wang et al., "Placement Matters: Understanding the Effects of Device Placement for WiFi Sensing," vol. 6, no. 1 Proc. ACM Interact. Mob. Wearable Ubiquitous Technol., p. Article 32, 2022.<br>
[3]H.Wang et al., "Human respiration detection with commodity wifi devices: do user location and body orientation matter?," presented at the Proceedings of the 2016 ACM International Joint Conference on Pervasive and Ubiquitous Computing, Heidelberg, Germany, 2016.<br>
