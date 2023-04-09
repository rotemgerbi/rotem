clear all

%% Define Parameters

% sampling frequency (Hz)
fs=100e6;

% length of time-domain signal
L=30e3;

% desired power specral density (dBm/Hz)
Pd=-100;

% number of FFT points
nfft=2^nextpow2(L);

% frequency plotting vector
f=fs/2*[-1:2/nfft:1-2/nfft];

% create
s=wgn(L,1,Pd+10*log10(fs),1,[],"dBm","complex");

%% Analysis

% analyze spectrum
N=nfft/2+1:nfft;
S=fftshift(fft(s,nfft));
S=abs(S)/sqrt(L*fs);

% time-average for spectrum
Navg=4e2;
b(1:Navg)=1/Navg;
Sa=filtfilt(b,1,S);

% convert to dBm/Hz
S=20*log10(S)+30;
Sa=20*log10(Sa)+30;
%% Plot
figure(1)
clf
plot(f(N)/1e6,S(N))
hold on
plot(f(N)/1e6,Sa(N),"r")
xlabel("Frequency (MHz)")
ylabel("Power Density (dBm/Hz)")
title(["Power Spectral Density"])
legend("Noise Spectrum","Time-Averaged Spectrum")
axis([10e-4 fs/2/1e6 -120 -60])
grid on
hold off
