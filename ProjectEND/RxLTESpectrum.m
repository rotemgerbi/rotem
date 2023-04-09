%% Reset
close all;
clear all;
clc;

%% Does work with SDR or from recording ?
flogSDR = " Does work with SDR or from recording ? "
flogSDR = input(flogSDR)

%% Setting up a work device
if (flogSDR)
    connectedRadios = findsdru;
    if strncmp(connectedRadios(1).Status, 'Success', 7)
        radioFound = true;
        platform = connectedRadios(1).Platform;
        switch connectedRadios(1).Platform
            case {'B200','B210'}
                address = connectedRadios(1).SerialNum;
            case {'N200/N210/USRP2','X300','X310','E312'}
                address = connectedRadios(1).IPAddress;
        end
    end
    
        radioRx = comm.SDRuReceiver(...
            'Platform', platform, ...
            'SerialNum', address,...
            'SamplesPerFrame',10000 );
        
        
        %% RX Parameters
        radioRx.CenterFrequency =900e6;
        radioRx.Gain =10;
        radioRx.MasterClockRate = 100e6;
        radioRx.OutputDataType = 'Single';
        radioRx.DecimationFactor=500;
        radioRx.LocalOscillatorOffset=1e6;
        
    
    %% Receiver
    %This function correlates between the two variables:lenoisySignal,Preamble_hMod.   
    FileSizeIs=0;
    while(~FileSizeIs)
        buffer=[];
        
        if radioFound
            timeCounter_zeroes =500;
            timeCounter_samples=100;
            for i=1:timeCounter_zeroes
                [temp, len] = step(radioRx);
            end
            for i=1:timeCounter_samples
                [x, len] = step(radioRx);
                 if(isreal(x))
                    break;
                end
                buffer=[buffer; x];
            end
            if(isreal(x))
                continue
            end
        end
    end
else 

    load eNodeBOutput.mat           % Load I/Q capture of eNodeB output
    figure;
    Complex_Pair_single = single(eNodeBOutput);
    stem(abs(fftshift(fft(Complex_Pair_single))));
    title('Buffer Samples');
    eNodeBOutput_New = [eNodeBOutput eNodeBOutput eNodeBOutput ];
    [Row,Column]     = size(eNodeBOutput_New);
    Signal           = zeros(Row , Column);
    for i = 1 : Column
        Signal (:,i) = AttenuatedB(eNodeBOutput_New(:,i));
        figure;
        plot(abs(fftshift(fft((double(Signal (:,i)))))));
    end
end
%% Setting spectrum 
SamplesPerSymbol = 10;%samples per Symbol*
BaudRate         = 20e6;%symbols/Second
% SamplingRate   = SamplesPerSymbol*BaudRate; % Sampling rate for loaded samples
SamplingRate     = 15.36e6;                   % Sampling rate for loaded samples

%% Plot Spectrum 
% Spectrum = dsp.SpectrumAnalyzer ('SampleRate',SamplingRate);
% info(Spectrum);
% while 1
%     step(Spectrum, ModeSignalNoise);
% end

%% Noise floor calculation and Channel strength calculation
ArayPower = zeros (Column,1);
for i = 1 : Column
    [~,~,~,power] = obw(  Signal (:,i));
    ArayPower(i,1) = power; 
end

[SizeMax,PlaceMax]=max(ArayPower);
SizeMax = 10*log10(SizeMax);

%% Plot GUI
GrapFFT = abs(fftshift(fft(Signal(:,PlaceMax))));
figure;
plot(GrapFFT);
title('The maximum graph')
xlabel("The maximum size " + SizeMax + " dB")
ylabel('Power')
