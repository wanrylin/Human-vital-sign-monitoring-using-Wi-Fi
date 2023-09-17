# Human vital sign monitoring using Wi-Fi 2021
My Final Year Project (FYP) cooperated with Lindy Zhou homepage:https://github.com/LINDYZHOU.  
Our superviser is Prof.Cuo Yongxin homepage:https://www.ece.nus.edu.sg/stfpage/eleguoyx/.

## Introduction
Due to the aging tendency and COVID-19 all over the world, the demand of non-contact vital sign monitoring is becoming more and more important. Compared to radar or high-quality camera, Wi-Fi devices are off-the-shelf, universal and low-cost. Therefore, great contribution has been made by the researchers all over the world on vital sign monitoring using Wi-Fi recently.
This project proposes a new system based on Wi-Fi CSI data. In the contrast to the pervious study, I introduce the latest IEEE 802.11ac/ax protocols into the system instead of IEEE 802.11n protocol as the sensing tool. Meanwhile, I extract both CSI amplitude and phase data as the input of the system from the network card. To reach better performance, I design two new subcarrier selection methods, SNR subcarrier selection and SSNR subcarrier selection. Furthermore, a new multi-person detection method is proposed via SSNR, which detection accuracy can be over 96%. The overall accuracy for breathing rate estimation is over 92% and for heart rate estimation is over 84%.

## Conditions and assumption
In order to make it clear about the situations that this paper is suitable for, some basic conditions are listed as follows:
(1)Wireless transmission protocol of the Wi-Fi device: IEEE 802.11ac/ax.
(2) Operating frequency band: 5GHz.
(3) Number of transmitting antennas: 2.
(4) Number of receiving antenna: 2
(5) Application senario: indoor LOS
(6) Sampling rate: 200Hz
(7) Posture of subject person: sit/lie

## Overview of the system
![overview of the system](https://github.com/wanrylin/Human-vital-sign-monitoring-using-Wi-Fi/blob/main/figures/system.png)
