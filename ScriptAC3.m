close all
clear all
clc
set(0,'defaultlinelinewidth',4)
set(0,'DefaultAxesFontSize', 24)

%Process FFT - the signal with noise
[sigwithnoise,samplfreq,~] = wavread('snowfall_w_noise.wav');
fft_sigwithnoise = fft(sigwithnoise);
figure
freq = (0:(numel(sigwithnoise)-1))*(samplfreq/numel(sigwithnoise));
plot(freq(1:end/2)./1e3,20*log10(abs(fft_sigwithnoise(1:end/2))),'k')
legend('FFT - sound wave')
xlabel('Frequency [kHz]')
ylabel('Amplitude dB')
title('FFT - recording with noise 5.017kHz')

%Find noise frequency assuming it is highly above the real signal amplitude
idx = find(abs(fft_sigwithnoise(1:end/2)) ==...
   max(abs(fft_sigwithnoise(1:end/2))));
noisefreq = freq(idx);

%Design a notch filter for removing the undesired noise 
[ax,ay,hz_zeros,hz_poles] = design_notchfilter(samplfreq,noisefreq,...
   0.9)

%Filter signal with the designed notch filter
filteredsignal = filter(ax,ay,sigwithnoise);

%Process FFT - the filtered signal
fft_filteredsig = fft(filteredsignal);
figure
freq = (0:(numel(fft_filteredsig)-1))*(samplfreq/numel(fft_filteredsig));
plot(freq(1:end/2)./1e3,20*log10(abs(fft_filteredsig(1:end/2))),'k')
legend('FFT - sound wave filtered')
xlabel('Frequency [kHz]')
ylabel('Amplitude dB')
title('FFT - recording after Notch Filter at 5.017kHz')

%Process FFT - signal without noise - reference signal
[wavein,samplfreq,~] = wavread('snowfall_wo_noise.wav');
fft_sigwithoutnoise = fft(wavein);

%Calculates the energy - the signal without noise - reference energy
referencesignal_energy = (1/numel(fft_sigwithoutnoise))*sum(abs(...
   fft_sigwithoutnoise).^2);

%calculates an approximate value for the noise energy based on its fft
fft_noisesig = fft_sigwithnoise-fft_sigwithoutnoise;
noise_energy = (1/numel(fft_noisesig))*sum(abs(fft_noisesig).^2);

%Plots the FFT - the noise extracted
figure
plot(freq(1:end/2)./1e3,20*log10(abs(fft_noisesig(1:end/2))),'k')
legend('FFT - noisePor')
xlabel('Frequency [kHz]')
ylabel('Amplitude dB')
title('FFT - the added Noise')

%calculates an approximate value for the new noise energy after the filter
fft_noisesig_afterfilter = fft_filteredsig-fft_sigwithoutnoise;
newnoise_energy = (1/numel(fft_noisesig_afterfilter))*sum(abs(...
   fft_noisesig_afterfilter).^2);

%SNR filtered and unfiltered calculations
snrunfiltered = 10*log10(referencesignal_energy)-10*log10(noise_energy)
snrfiltered = 10*log10(referencesignal_energy)-10*log10(newnoise_energy)

%Difference between old and new SNR
NewSNR = snrfiltered - snrunfiltered
%JUST ADD COMMENT FOR GIT DIFF
